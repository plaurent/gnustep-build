# gnustep-build

This repository contains scripts for building the latest GNUstep from source under your favorite distributions.  Tested features include blocks and ARC.

See `demo.sh` and `demo-gui.sh` for barebones examples.

## Build Status

Platform specific build status via Github Actions (on fresh installs of the distribution using Docker):

Distribution | objc runtime | supports ARC | supports Blocks | installs clang | CI Status
-------------|-----|-----|-----|-----|:---------
Ubuntu 16.04 | 1.9 | yes | yes | 6.0 | [![Ubuntu 16.04 Build Status](https://github.com/plaurent/gnustep-build/actions/workflows/ub1604c6r19.yml/badge.svg)](https://github.com/plaurent/gnustep-build/actions/workflows/ub1604c6r19.yml)
Ubuntu 20.04 | 2.0 | yes | yes | 10.0 | [![Ubuntu 20.04 Build Status](https://github.com/plaurent/gnustep-build/actions/workflows/ub2004c10r20.yml/badge.svg)](https://github.com/plaurent/gnustep-build/actions/workflows/ub2004c10r20.yml)
Debian 10    | 2.0 | yes | yes | 8.0 |  [![Debian 10 Build Status](https://github.com/plaurent/gnustep-build/actions/workflows/deb10c8r20.yml/badge.svg)](https://github.com/plaurent/gnustep-build/actions/workflows/deb10c8r20.yml)
