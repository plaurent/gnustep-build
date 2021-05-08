# gnustep-build

All tested builds: [![Build Status](https://travis-ci.com/plaurent/gnustep-build.svg?branch=master)](https://travis-ci.com/plaurent/gnustep-build)

This repository contains scripts for building the latest GNUstep from source under your favorite distributions.  Tested features include blocks and ARC.

See `demo.sh` and `demo-gui.sh` for barebones examples.

Platform specific build status via Github Actions (on fresh installs of the distribution using Docker):

* ub1604c6r19 ![ub1604c6r19](https://github.com/plaurent/gnustep-build/actions/workflows/ub1604c6r19.yml/badge.svg)
* ub2004c10r20 ![ub2004c10r20](https://github.com/plaurent/gnustep-build/actions/workflows/ub2004c10r20.yml/badge.svg)
* ub2010c11r20 ![ub2010c11r20](https://github.com/plaurent/gnustep-build/actions/workflows/ub2010c11r20.yml/badge.svg)

Platform specific build status via travis-ci.org (on fresh installs of the distribution using Docker):

Distribution | objc runtime | supports ARC | supports Blocks | installs clang | CI Status
-------------|-----|-----|-----|-----|:---------
Ubuntu 16.04 | 1.9 | yes | yes | 6.0 | [![Ubuntu 16.04 Build Status](http://badges.herokuapp.com/travis/plaurent/gnustep-build?env=BADGE=ubuntu1604&label=build&branch=master)](https://travis-ci.org/plaurent/gnustep-build)
Ubuntu 19.10 | 2.0 | yes | yes | 9.0 | [![Ubuntu 19.04 Build Status](http://badges.herokuapp.com/travis/plaurent/gnustep-build?env=BADGE=ubuntu1910&label=build&branch=master)](https://travis-ci.org/plaurent/gnustep-build)
Debian 10    | 2.0 | yes | yes | 8.0 |  [![Debian 10 Build Status](http://badges.herokuapp.com/travis/plaurent/gnustep-build?env=BADGE=debian10&label=build&branch=master)](https://travis-ci.org/plaurent/gnustep-build)
libobjc2 under Ubuntu 19.10 | 2.0 | yes | yes | 9.0 | [![Ubuntu 19.04 Build Status](http://badges.herokuapp.com/travis/plaurent/gnustep-build?env=BADGE=ubuntu1910-libobjc2test&label=build&branch=master)](https://travis-ci.org/plaurent/gnustep-build)
