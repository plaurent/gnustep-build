#!/bin/bash

# Show prompt function
function showPrompt()
{
  if [ "$PROMPT" = true ] ; then
    echo -e "\n\n"
    read -p "${GREEN}Press enter to continue...${NC}"
  fi
}

# Set colors
GREEN=`tput setaf 2`
NC=`tput sgr0` # No Color

# Set to true to also build and install apps
APPS=false

# Set to true to also build and install GNUstep themes
THEMES=false

# Set to true to pause after each build to verify successful build and installation
PROMPT=false

# Install Requirements
sudo apt update


echo -e "\n\n${GREEN}Installing dependencies...${NC}"

sudo apt-get update
sudo apt -y install build-essential git subversion clang-9 \
libpthread-workqueue0 libpthread-workqueue-dev \
libxml2 libxml2-dev \
libffi6 libffi-dev \
libuuid1 uuid-dev uuid-runtime \
libsctp1 libsctp-dev lksctp-tools \
libavahi-common3 libavahi-common-dev libavahi-common-data \
libgcrypt20 libgcrypt20-dev \
libbsd0 libbsd-dev \
util-linux-locales \
locales-all \
libc-dev libc++-dev libc++1 \
libedit-dev libeditline0 libeditline-dev \
binfmt-support libtinfo-dev \
bison flex m4 wget \
libicns1 libicns-dev \
libxslt1.1 libxslt1-dev \
libxft2 libxft-dev \
libflite1 flite1-dev \
libxmu6 libxpm4 wmaker-common \
libgnutls30 libgnutls28-dev \
default-libmysqlclient-dev \
libpq-dev \
libstdc++-6-dev \
gobjc-6 gobjc++-6 \
gobjc++ \
libstdc++-6-dev libstdc++-6-doc libstdc++-6-pic \
libstdc++6 cmake xpdf libxrandr-dev libcurl4-gnutls-dev

if [ "$APPS" = true ] ; then
  sudo apt -y install curl
fi

# Create build directory
mkdir GNUstep-build
cd GNUstep-build

# Set clang as compiler
export CC=clang-9
export CXX=clang++-9
export RUNTIME_VERSION=gnustep-2.1
export LD=/usr/bin/ld.gold
export LDFLAGS="-fuse-ld=gold -L/usr/local/lib"


# Checkout sources
echo -e "\n\n${GREEN}Checking out sources...${NC}"
git clone https://github.com/apple/swift-corelibs-libdispatch
cd swift-corelibs-libdispatch
  git checkout swift-5.1.1-RELEASE 
cd ..

git clone https://github.com/gnustep/libobjc2.git
cd libobjc2
#  git checkout 2.1  
  git submodule init && git submodule update
cd ..
git clone https://github.com/gnustep/tools-make.git
git clone https://github.com/gnustep/libs-base.git
git clone https://github.com/gnustep/libs-corebase.git

showPrompt

set -e
# Build GNUstep make first time
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-make for the first time...${NC}"
cd tools-make
# git checkout `git rev-list -1 --first-parent --before=2017-04-06 master` # fixes segfault, should probably be looked at.
./configure --enable-debug-by-default --with-layout=gnustep  --enable-objc-arc  --with-library-combo=ng-gnu-gnu
make -j4
sudo -E make install

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh
echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> ~/.bashrc
echo "export RUNTIME_VERSION=$RUNTIME_VERSION" >> ~/.bashrc


showPrompt

## Build libDIspatch
echo -e "\n\n"
echo -e "${GREEN}Building libdispatch...${NC}"
cd ../swift-corelibs-libdispatch
rm -Rf build
mkdir build && cd build
cmake .. -DCMAKE_C_COMPILER=${CC} \
	-DCMAKE_CXX_COMPILER=${CXX} \
	-DCMAKE_BUILD_TYPE=Release \
	-DUSE_GOLD_LINKER=YES
make
sudo -E make install
sudo ldconfig

showPrompt

# Build libobjc2
echo -e "\n\n"
echo -e "${GREEN}Building libobjc2...${NC}"
cd ../../libobjc2
rm -Rf build
mkdir build && cd build
cmake ../ -DCMAKE_C_COMPILER=clang-9 -DCMAKE_CXX_COMPILER=clang++-9 -DCMAKE_ASM_COMPILER=clang-9 -DTESTS=OFF
cmake --build .
sudo -E make install
sudo ldconfig

showPrompt

# Build GNUstep make second time
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-make for the second time...${NC}"
cd ../../tools-make
./configure --enable-debug-by-default --with-layout=gnustep --enable-objc-arc --with-library-combo=ng-gnu-gnu
make -j8
sudo -E make install

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

showPrompt

# Build GNUstep corebase (CoreFoundation)
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-corebase...${NC}"
cd ../libs-corebase/
./configure
make -j8
sudo -E make install

showPrompt

# Build GNUstep base
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-base...${NC}"
cd ../libs-base/
./configure
make -j8
sudo -E make install

showPrompt

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh


echo -e "\n\n"
echo -e "${GREEN}Install is done. Open a new terminal to start using.${NC}"
