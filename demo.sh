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
   [frac release];

   return 0;
}
EOF

cat > helloGCD_ARC_objc.m << EOF
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
   if (__has_feature(objc_arc)) {
     printf("ARC is working.");
     return 0;
   } else {
     printf("ARC is not working.");
     return -1;
   }
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



# ======================================================================
# COMPILE USING THE FOLLOWING COMMAND LINES, OR CREATE A MAKEFILE
# ======================================================================

# Set compiler
if [ -x "$(command -v ${CC})" ]; then
  echo "Using CC from environment variable: ${CC}"
else
  if [ -x "$(command -v clang-9)" ]; then
    CC=clang-9
  elif [ -x "$(command -v clang-11)" ]; then
    CC=clang-11
  elif [ -x "$(command -v clang-8)" ]; then
    CC=clang-8
  elif [ -x "$(command -v clang-6.0)" ]; then
    CC=clang-6.0
  elif [ -x "$(command -v clang)" ]; then
    CC=clang
  else
    echo 'Error: clang seems not to be in PATH. Please check your $PATH.' >&2
    exit 1
  fi
fi

# Using COMMAND LINE
echo "Compiling and running blocks demo."
${CC} `gnustep-config --objc-flags` `gnustep-config --objc-libs` -lobjc  blocktest.m
./a.out

echo "Compiling and running Grand Central Dispatch demo."
${CC} `gnustep-config --objc-flags` `gnustep-config --objc-libs` -lobjc -ldispatch -lgnustep-base  Fraction.m helloGCD_objc.m
./a.out

# Using MAKEFILE

cat > GNUmakefile << EOF
include \$(GNUSTEP_MAKEFILES)/common.make
APP_NAME = FractionDemo
LDFLAGS = -ldispatch
FractionDemo_OBJC_FILES = Fraction.m helloGCD_objc.m
include \$(GNUSTEP_MAKEFILES)/application.make
EOF

echo "Compiling and running Fraction demo (makefile compilation)."
make
openapp ./FractionDemo.app


# Using MAKEFILE with enabled ARC

cat > GNUmakefile << EOF
include \$(GNUSTEP_MAKEFILES)/common.make
OBJCFLAGS = -fobjc-arc
LDFLAGS = -ldispatch
APP_NAME = FractionArcDemo
FractionArcDemo_OBJC_FILES = Fraction.m helloGCD_ARC_objc.m
include \$(GNUSTEP_MAKEFILES)/application.make
EOF

echo "Compiling and running Fraction ARC demo (makefile compilation)."
make
openapp ./FractionArcDemo.app
