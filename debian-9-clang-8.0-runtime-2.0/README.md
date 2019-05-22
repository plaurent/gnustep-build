# Build GNUstep on Debian stable (stretch)

## What's this?

This script is based on the for Ubuntu which can be found in its directory and [extensive compilation instructions](http://wiki.gnustep.org/index.php/Building_GNUstep_under_Debian_FreeBSD) by Andreas Fink. The aim of the script is to build the most current version of GNUstep (including GNUstep libobjc2) on Debian stable, which should be compiled using clang instead of using GCC.

We are going compile libobjc2 master (2.0/2.1), which requires clang 8 at least.

## How to use

### 1. Include the LLVM repository

To get clang-8 you need to install it from the LLVM repository (https://apt.llvm.org/). Make sure you have these lines in `/etc/apt/sources.list`

```
deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-8 main
deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-8 main
```

To retrieve the archive signature:
```
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
# Fingerprint: 6084 F3CF 814B 57C1 CF12 EFD5 15CF 4D18 AF4F 7421 
```

Update the package list and upgrade your system:

```
sudo apt update
sudo apt upgrade
```

### 2. Execute the script

Save the raw script to disk. Place it in a nice and cosy place (f.e. your home dir) and execute it:

```
chmod +x GNUstep-buildon-debian.sh
./GNUstep-buildon-debian.sh
```

As default this script will install the GNUstep runtime, the most important apps and three nice themes. If you do not need one of those set the corresponding variable in the script to ```false```.

Execution of the script may take some time. If all goes well, you will have a working and up to date GNUstep installation after.


### 3. Optional: Get a nice Mac like look

**Update (2019/05/22): Please note that rik.theme is not going to work using the current setup due to linking issues (ivar types either seem to be incompatible with libs-gui or there is access of private ivars which is not compatible with clang).** I suggest using one of the other two themes that do not need compilation/linking.

As a person used to work with a Mac I suggest you put the following settings in place to get a nice look for your GNUstep apps that is similar to [this one](https://github.com/BertrandDekoninck/rik.theme/blob/master/newscreen.png):

1. Start System Preferences.app: 

   `openapp SystemPreferences &`

2. Start the Theme plugin and select and enable f.e. theme "Rik".

3. Go back, start the Defaults plugin and:
   - set "NSInterfaceStyleDefault" to "NSMacintoshInterfaceStyle"
   - set "NSMenuInterfaceStyle" to "NSMacintoshInterfaceStyle"

4. Quit System Preferences.app and start the workspace app:

  `openapp GWorkspace`

  You will find your apps at `/usr/GNUstep/Local/Applications/`. Have fun!

THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE. Always backup your data!
