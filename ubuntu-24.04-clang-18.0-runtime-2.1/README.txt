This version for Ubuntu24.04 adds a dependency for g++-14.  The reason is as follows.

On a stock version of Ubuntu24, clang-18 finds two candidate installations of gcc at the following
       /usr/lib/gcc/x86_64-linux-gnu/13
       /usr/lib/gcc/x86_64-linux-gnu/14
clang-18 chooses the highest number (14) but this one is incomplete - it does not have libstdc++.
Adding the g++-14 dependency completes the installation.

In the future this dependency will probably no longer be required.
