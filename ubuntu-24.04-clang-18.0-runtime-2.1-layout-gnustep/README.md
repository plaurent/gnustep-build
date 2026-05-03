# Build GNUstep on Ubuntu 24.04 - GNUstep layout

This variant of the build script is based upon the one for Debian 10/12 to provide
a GNUstep installation supporting libobjc2, but using the GNUstep file system layout.

I prefer that one, because in case of broken setups you may just delete `/usr/GNUstep`
and start anew. I find that way easier than fiddling the stuff out of `/usr/local/$X`.

## Hints and problems

* Make sure to remove/uninstall any residents of previous GNUstep installations. Otherwise configurations may get mixed up in a bad way.

## G++-14

This version for Ubuntu24.04 adds a dependency for g++-14.  The reason is as follows.

On a stock version of Ubuntu24, clang-18 finds two candidate installations of gcc at the following
       /usr/lib/gcc/x86_64-linux-gnu/13
       /usr/lib/gcc/x86_64-linux-gnu/14
clang-18 chooses the highest number (14) but this one is incomplete - it does not have libstdc++.
Adding the g++-14 dependency completes the installation.

In the future this dependency will probably no longer be required.
