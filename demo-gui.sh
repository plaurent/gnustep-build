#!/bin/bash

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
