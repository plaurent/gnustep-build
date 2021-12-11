#!/bin/bash

cat > guitest.m << EOF
#import <AppKit/AppKit.h>
#import "AppDelegate.h"

int main()
{
  NSApplication *app = [NSApplication sharedApplication];
  NSWindow* delegate = [[AppDelegate alloc] init];
  [app setDelegate:delegate];
  [app run];
}
EOF

cat > AppDelegate.h << EOF
#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>

@interface AppDelegate:NSWindow
- (void)applicationDidFinishLaunching:(NSNotification*)aNotification;
@end
EOF

cat > AppDelegate.m << EOF
#include "AppDelegate.h"

@implementation AppDelegate : NSWindow

- (id)init {
  return self;
}

- (void)applicationDidFinishLaunching:(NSNotification*)aNotification
{
  [self orderFront:self];
  NSAlert* alert = [[NSAlert alloc] init];
  [alert setMessageText:@"Hello alert"];
  [alert addButtonWithTitle:@"All done"];
  int result = [alert runModal];
  if (result == NSAlertFirstButtonReturn) {
    NSLog(@"First button pressed");
  }
  NSApplication* app = [NSApplication sharedApplication];
  [app terminate:self];
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
echo "Compiling and running GUI + ARC demo (command line compilation)."
${CC} `gnustep-config --objc-flags` `gnustep-config --objc-libs` -lobjc -fobjc-arc -ldispatch -lgnustep-base -lgnustep-gui  guitest.m AppDelegate.m
./a.out

# Using MAKEFILE
cat > GNUmakefile << EOF
include \$(GNUSTEP_MAKEFILES)/common.make
OBJCFLAGS = -fobjc-arc
LDFLAGS = -ldispatch
APP_NAME = GUITest
GUITest_OBJC_FILES = guitest.m AppDelegate.m
include \$(GNUSTEP_MAKEFILES)/application.make
EOF

echo "Compiling and running GUI + ARC demo (makefile compilation)."
make
openapp ./GUITest.app
