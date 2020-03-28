#!/bin/bash

## Script to install the newest available version of GNUstep on Debian stable (stretch)
## based on the script for Ubuntu, originating from http://wiki.gnustep.org/index.php/GNUstep_under_Ubuntu_Linux.

## Before executing this script make sure you have clang installed from apt.llvm.org, see README for instructions.

# Show prompt function
function showPrompt()
{
  if [ "$PROMPT" = true ] ; then
    echo -e "\n\n"
    read -p "${GREEN}Press enter to continue...${NC}"
  fi
}

# Export compiler environment vars
export CC=clang-8
export CXX=clang++-8
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export RUNTIME_VERSION=gnustep-2.0
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export LD=/usr/bin/ld.gold
export LDFLAGS="-fuse-ld=/usr/bin/ld.gold -L/usr/local/lib"
export OBJCFLAGS="-fblocks"

function installGNUstepMake()
{
  echo -e "\n\n"
  echo -e "${GREEN}Building GNUstep-make...${NC}"
  cd ../make
  make clean
  CC=clang-8 ./configure \
    --with-layout=gnustep \
    --disable-importing-config-file \
    --enable-native-objc-exceptions \
    --enable-objc-arc \
    --enable-install-ld-so-conf \
    --with-library-combo=ng-gnu-gnu
  make -j8
  sudo -E make install
  sudo ldconfig
}

# Set colors
GREEN=`tput setaf 2`
NC=`tput sgr0` # No Color

# Set to true to also build and install apps
APPS=true

# Set to true to also build and install some nice themes
THEMES=false

# Set to true to pause after each build to verify successful build and installation
PROMPT=true

# Install Requirements
sudo apt update

echo -e "\n\n${GREEN}Installing dependencies...${NC}"

sudo dpkg --add-architecture i386  # Enable 32-bit repos for libx11-dev:i386
sudo apt-get update
sudo echo "deb http://apt.llvm.org/stretch/ llvm-toolchain-stretch-8 main deb-src http://apt.llvm.org/stretch/ llvm-toolchain-stretch-8 main" > /etc/apt/sources.list.d/llvm.list
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
sudo apt-get update
sudo apt -y remove clang
DEBIAN_FRONTEND=noninteractive sudo apt -y install clang-8 liblldb-8 lld-8 build-essential git subversion \
libpthread-workqueue0 libpthread-workqueue-dev \
libxml2 libxml2-dev \
libffi6 libffi-dev \
libicu-dev \
libuuid1 uuid-dev uuid-runtime \
libsctp1 libsctp-dev lksctp-tools \
libavahi-core7 libavahi-core-dev \
libavahi-client3 libavahi-client-dev \
libavahi-common3 libavahi-common-dev libavahi-common-data \
libgcrypt20 libgcrypt20-dev \
libtiff5 libtiff5-dev \
libbsd0 libbsd-dev \
util-linux-locales \
locales-all \
libjpeg-dev \
libtiff-dev \
libcups2-dev \
libfreetype6-dev \
libcairo2-dev \
libxt-dev \
libgl1-mesa-dev \
libpcap-dev \
libc-dev libc++-dev libc++1 \
python-dev swig \
libedit-dev libeditline0 libeditline-dev \
binfmt-support libtinfo-dev \
bison flex m4 wget \
libicns1 libicns-dev \
libxslt1.1 libxslt1-dev \
libxft2 libxft-dev \
libflite1 flite1-dev \
libxmu6 libxpm4 wmaker-common \
libgnutls30 libgnutls28-dev \
libpng-dev libpng16-16 \
default-libmysqlclient-dev \
libpq-dev \
libstdc++-6-dev \
gobjc-6 gobjc++-6 \
gobjc++ \
libgif7 libgif-dev libwings3 libwings-dev libwraster5 \
libwraster-dev libwutil5 \
libcups2-dev libicu57 libicu-dev \
xorg \
libfreetype6 libfreetype6-dev \
libpango1.0-dev \
libcairo2-dev \
libxt-dev libssl-dev \
libasound2-dev libjack-dev libjack0 libportaudio2 \
libportaudiocpp0 portaudio19-dev \
libstdc++-6-dev libstdc++-6-doc libstdc++-6-pic \
libstdc++6 wmaker cmake xpdf libxrandr-dev

# readline-common libreadline7 libreadline-dev cmake-curses-gui
sudo rm /usr/lib/libobjc*

if [ "$APPS" = true ] ; then
  sudo apt -y install curl
fi

# Create build directory
mkdir GNUstep-build
cd GNUstep-build

# Checkout sources
echo -e "\n\n${GREEN}Checking out sources...${NC}"
# Uncomment this if libkqueue is still needed
wget http://ftp.gnu.org/pub/gnu/libiconv/libiconv-1.15.tar.gz
git clone https://github.com/apple/swift-corelibs-libdispatch
cd swift-corelibs-libdispatch
  git checkout swift-5.1.1-RELEASE
cd ..

git clone https://github.com/gnustep/scripts
git clone https://github.com/gnustep/make
git clone https://github.com/gnustep/libobjc2
cd libobjc2
  git submodule init
  git submodule sync
  git submodule update
cd ..
git clone https://github.com/gnustep/base
git clone https://github.com/gnustep/corebase
git clone https://github.com/gnustep/gui
git clone https://github.com/gnustep/back

if [ "$APPS" = true ] ; then
  git clone https://github.com/gnustep/apps-projectcenter.git
  git clone https://github.com/gnustep/apps-gorm.git
  wget http://savannah.nongnu.org/download/gap/PDFKit-1.0.1.tar.gz
  git clone https://github.com/gnustep/apps-gworkspace.git
  git clone https://github.com/gnustep/apps-systempreferences.git
fi

if [ "$THEMES" = true ] ; then
  git clone https://github.com/BertrandDekoninck/NarcissusRik.git
  git clone https://github.com/BertrandDekoninck/NesedahRik.git
#  git clone https://github.com/BertrandDekoninck/rik.theme.git
fi

showPrompt

# We compile libiconv. Debian comes standard with version 1.14 but there was an issue in 1.14
# which got fixed in 1.15 which was relevant to us so using 1.15 is recommended.
echo -e "\n\n"
echo -e "${GREEN}Building libiconv...${NC}"
tar -xvzf libiconv-1.15.tar.gz
cd libiconv-1.15
./configure --enable-static --enable-dynamic
make clean
make
sudo -E make install

showPrompt

installGNUstepMake


echo $LDFLAGS
echo $OBJCFLAGS
. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh
echo $LDFLAGS
echo $OBJCFLAGS
echo "export RUNTIME_VERSION=$RUNTIME_VERSION"  >> ~/.bashrc
echo "export LD=/usr/bin/ld.gold" >> ~/.bashrc
echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> ~/.bashrc

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
cmake .. -DCMAKE_BUILD_TYPE=Release \
-DBUILD_STATIC_LIBOBJC=1 \
-DCMAKE_C_COMPILER=${CC} \
-DCMAKE_CXX_COMPILER=${CXX} \
-DCMAKE_LINKER=${LD} \
-DCMAKE_MODULE_LINKER_FLAGS="${LDFLAGS}"
make -j8
sudo -E make install
sudo ldconfig
cd ..

showPrompt

# Build GNUstep make second time

installGNUstepMake

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

showPrompt

# Build GNUstep base
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-base...${NC}"
cd ../base/
make clean
#./configure --with-config-file=/usr/local/etc/GNUstep/GNUstep.conf --with-libiconv-library=/usr/local/lib
./configure --with-libiconv-library=/usr/local/lib
make -j8
sudo -E make install
sudo ldconfig

showPrompt

# Build GNUstep corebase
#echo -e "\n\n"
#echo -e "${GREEN}Building GNUstep corebase...${NC}"
#cd ../corebase
#make clean
#./configure
#make -j8
#sudo -E make install
#sudo ldconfig

showPrompt

# Build GNUstep GUI
echo -e "\n\n"
echo -e "${GREEN} Building GNUstep-gui...${NC}"
cd ../gui
make clean
./configure
make -j8
sudo -E make install
sudo ldconfig

showPrompt

# Build GNUstep back
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-back...${NC}"
cd ../back
make clean
./configure
make -j8
sudo -E make install
sudo ldconfig

showPrompt

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

export LDFLAGS="-fuse-ld=/usr/bin/ld.gold -L/usr/local/lib"
ldconfig

installGNUstepMake
if [ "$APPS" = true ] ; then
  echo -e "${GREEN}Building ProjectCenter...${NC}"
  cd ../apps-projectcenter/
  make clean
  make -j8
  sudo -E make install

  showPrompt

  echo -e "${GREEN}Building Gorm...${NC}"
  cd ../apps-gorm/
  make clean
  make -j8
  sudo -E make install

  showPrompt

  echo -e "${GREEN}Building PDFKit...${NC}"
  cd ..
  tar xzf PDFKit-1.0.1.tar.gz
  cd PDFKit-1.0.1/
  ./configure
  make -j8
  sudo -E make install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building GWorkspace...${NC}"
  cd ../apps-gworkspace/
  make clean
  ./configure
  make -j8
  sudo -E make install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building SystemPreferences...${NC}"
  cd ../apps-systempreferences/
  make clean
  make -j8
  sudo -E make install

fi

if [ "$THEMES" = true ] ; then

  showPrompt

#rik.theme build will fail currently, see README for details
#  echo -e "\n\n"
#  echo -e "${GREEN}Building rik.theme...${NC}"
#  cd ../rik.theme/
#  make clean
#  make -j8
#  sudo -E make install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NesedahRik.theme...${NC}"
  cd ../NesedahRik/
  sudo cp -R NesedahRik.theme /usr/GNUstep/Local/Library/Themes/

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NarcissusRik.theme...${NC}"
  cd ../NarcissusRik/
  sudo cp -R NarcissusRik.theme /usr/GNUstep/Local/Library/Themes/
fi

echo -e "\n\n"
echo -e "${GREEN}Install is done. Open a new terminal to start using.${NC}"
