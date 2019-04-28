#!/bin/bash

cat > blocktest.m << EOF
#include <stdio.h>

int main() {
    void (^hello)(void) = ^(void) {
        printf("Hello, block!\n");
    };
    hello();
    return 0;
}
EOF

cat > helloGCD_objc.m << EOF

#include <dispatch/dispatch.h>
#import <stdio.h>
#import "Fraction.h"

int main( int argc, const char *argv[] ) {
   dispatch_queue_t queue = dispatch_queue_create(NULL, NULL);
   Fraction *frac = [[Fraction alloc] init];

   [frac setNumerator: 1];
   [frac setDenominator: 3];

   // print it
   dispatch_sync(queue, ^{
     printf( "The fraction is: " );
     [frac print];
     printf( "\n" );
   });
   dispatch_release(queue);

   return 0;
}

EOF

cat > Fraction.h << EOF

#import <Foundation/NSObject.h>

@interface Fraction: NSObject {
   int numerator;
   int denominator;
}

-(void) print;
-(void) setNumerator: (int) n;
-(void) setDenominator: (int) d;
-(int) numerator;
-(int) denominator;
@end

EOF


cat > Fraction.m << EOF
#import "Fraction.h"
#import <stdio.h>

@implementation Fraction
-(void) print {
   printf( "%i/%i", numerator, denominator );
}

-(void) setNumerator: (int) n {
   numerator = n;
}

-(void) setDenominator: (int) d {
   denominator = d;
}

-(int) denominator {
   return denominator;
}

-(int) numerator {
   return numerator;
}
@end

EOF



cat > guitest.m << EOF
#import <AppKit/AppKit.h>

int main()
{
  NSApplication *app;  // Without these 2 lines, seg fault may occur
  app = [NSApplication sharedApplication];

  NSAlert * alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Hello alert"];
  [alert addButtonWithTitle:@"All done"];
  int result = [alert runModal];
  if (result == NSAlertFirstButtonReturn) {
    NSLog(@"First button pressed");
  }
}
EOF

# ======================================================================
# COMPILE USING THE FOLLOWING COMMAND LINES, OR CREATE A MAKEFILE
# ======================================================================

# Using COMMAND LINE

echo "Compiling and running blocks demo."
clang `gnustep-config --objc-flags` `gnustep-config --objc-libs` -lobjc  blocktest.m
./a.out

echo "Compiling and running Grand Central Dispatch demo."
clang `gnustep-config --objc-flags` `gnustep-config --objc-libs` -lobjc -ldispatch -lgnustep-base  Fraction.m helloGCD_objc.m
./a.out


echo "Compiling and running GUI demo (command line compilation)."
clang `gnustep-config --objc-flags` `gnustep-config --objc-libs` -lobjc -fobjc-arc -ldispatch -lgnustep-base -lgnustep-gui  guitest.m
./a.out

# Using MAKEFILE

cat > GNUmakefile << EOF
include \$(GNUSTEP_MAKEFILES)/common.make

APP_NAME = GUITest
GUITest_OBJC_FILES = guitest.m

include \$(GNUSTEP_MAKEFILES)/application.make
EOF

echo "Compiling and running GUI demo (makefile compilation)."
make
openapp ./GUITest.app
