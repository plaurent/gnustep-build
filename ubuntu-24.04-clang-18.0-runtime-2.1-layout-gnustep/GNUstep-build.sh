#!/bin/bash

# Show prompt function
function showPrompt()
{
  if [ "$PROMPT" = true ] ; then
    echo -e "\n\n"
    read -p "${GREEN}Press enter to continue...${NC}"
  fi
}

# Export compiler environment vars
export CC=clang
export CXX=clang++
export PATH="$PATH:/usr/GNUstep/System/Tools"
export RUNTIME_VERSION=gnustep-2.1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export LD=/usr/bin/ld.gold
export LDFLAGS="-fuse-ld=/usr/bin/ld.gold -L/usr/local/lib"
export OBJCFLAGS="-fblocks"

# Set colors
GREEN=`tput setaf 2`
NC=`tput sgr0` # No Color

# Set to true to also build and install apps
APPS=false

# Set to true to also build and install some nice themes
THEMES=false

# Set to true to pause after each build to verify successful build and installation
PROMPT=false

function installGNUstepMake()
{
  echo -e "\n\n"
  echo -e "${GREEN}Building GNUstep-make...${NC}"
  cd tools-make
  make clean
  CC=clang ./configure \
    --with-layout=gnustep \
    --disable-importing-config-file \
    --enable-native-objc-exceptions \
    --enable-objc-arc \
    --enable-install-ld-so-conf \
    --with-library-combo=ng-gnu-gnu
  sudo -E make install
  cd ..
  sudo ldconfig
}

# Install Requirements
echo -e "\n\n${GREEN}Installing dependencies...${NC}"

sudo apt-get update
sudo apt -y install clang build-essential wget git subversion cmake libffi-dev libxml2-dev \
libgnutls28-dev libicu-dev libblocksruntime-dev libkqueue-dev libpthread-workqueue-dev autoconf libtool \
libjpeg-dev libtiff-dev libffi-dev libcairo-dev libx11-dev libxt-dev libxft-dev libxrandr-dev \
g++-14

if [ "$APPS" = true ] ; then
  sudo apt -y install curl
fi

# Create build directory
mkdir GNUstep-build
cd GNUstep-build

# Checkout sources
echo -e "\n\n${GREEN}Checking out sources...${NC}"
git clone https://github.com/apple/swift-corelibs-libdispatch

git clone https://github.com/gnustep/libobjc2
cd libobjc2
  git submodule init
  git submodule sync
  git submodule update
cd ..

git clone https://github.com/gnustep/tools-make.git
git clone https://github.com/gnustep/libs-base.git
git clone https://github.com/gnustep/libs-corebase.git
git clone https://github.com/gnustep/libs-gui.git
git clone https://github.com/gnustep/libs-back.git

if [ "$APPS" = true ] ; then
  git clone https://github.com/gnustep/apps-projectcenter.git
  git clone https://github.com/gnustep/apps-gorm.git
  svn co http://svn.savannah.nongnu.org/svn/gap/trunk/libs/PDFKit/
  git clone https://github.com/gnustep/apps-gworkspace.git
  git clone https://github.com/gnustep/apps-systempreferences.git
fi

if [ "$THEMES" = true ] ; then
  git clone https://github.com/gnustep/plugins-themes-nesedahrik.git
  git clone https://github.com/gnustep/plugins-themes-narcissusrik.git
  git clone https://github.com/gnustep/plugins-themes-sombre.git
  git clone https://github.com/mclarenlabs/rik.theme.git
fi

showPrompt

echo "export RUNTIME_VERSION=$RUNTIME_VERSION" >> ~/.bashrc
echo "export LD=/usr/bin/ld.gold" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/GNUstep/System/Library/Libraries/" >> ~/.bashrc
echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> ~/.bashrc

## Build libDispatch
echo -e "\n\n"
echo -e "${GREEN}Building libdispatch...${NC}"
cd swift-corelibs-libdispatch
rm -Rf build
mkdir build && cd build
cmake ../ -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	 -DCMAKE_SKIP_RPATH=ON \
	 -DCMAKE_BUILD_TYPE='None' \
	 -DCMAKE_INSTALL_PREFIX=/usr/GNUstep \
	 -DCMAKE_INSTALL_LIBDIR=/usr/GNUstep/System/Library/Libraries/ \
	 -DCMAKE_INSTALL_MANDIR=/usr/GNUstep/System/Library/Documentation/man/ \
	 -DINSTALL_DISPATCH_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/dispatch \
	 -DINSTALL_BLOCK_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/block \
	 -DINSTALL_OS_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/os \
	 -DINSTALL_PRIVATE_HEADERS=YES
make -j8
sudo -E make install
cd ../..
sudo rm /usr/GNUstep/System/Library/Headers/block/Block.h
sudo rm /usr/GNUstep/System/Library/Headers/block/Block_private.h
sudo ldconfig

showPrompt

# Install GNUstep make for the first time so libobjc2 picks up the correct file system layout.
installGNUstepMake

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

showPrompt

# Build libobjc2
echo -e "\n\n"
echo -e "${GREEN}Building libobjc2...${NC}"
cd libobjc2
rm -Rf build
mkdir build && cd build
cmake ../ -DCMAKE_C_COMPILER=$CC -DCMAKE_CXX_COMPILER=$CXX -DCMAKE_ASM_COMPILER=$CC -DTESTS=OFF
make -j8
sudo -E make install
sudo ldconfig
cd ../..

showPrompt

# Install GNUstep make for the second time to GNUstep make is configured to use libobjc2.
installGNUstepMake

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

showPrompt

# Build GNUstep base
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-base...${NC}"
cd libs-base
make clean
./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
cd ..
sudo ldconfig

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

showPrompt

# Build GNUstep corebase
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep corebase (set CFLAGS)...${NC}"
cd libs-corebase
CPP=`gnustep-config --variable=CPP` CPPFLAGS=`gnustep-config --objc-flags` CC=`gnustep-config --variable=CC` CFLAGS=`gnustep-config --objc-flags` LDFLAGS=`gnustep-config --objc-libs` ./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
cd ..
sudo ldconfig

showPrompt

# Build GNUstep GUI
echo -e "\n\n"
echo -e "${GREEN} Building GNUstep-gui...${NC}"
cd libs-gui
make clean
./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
cd ..
sudo ldconfig

showPrompt

# Build GNUstep back
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-back...${NC}"
cd libs-back
make clean
./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
cd ..
sudo ldconfig

showPrompt

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

export LDFLAGS="-fuse-ld=/usr/bin/ld.gold"
sudo ldconfig

installGNUstepMake
if [ "$APPS" = true ] ; then
  echo -e "${GREEN}Building ProjectCenter...${NC}"
  cd apps-projectcenter/
  make clean
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..

  showPrompt

  echo -e "${GREEN}Building Gorm...${NC}"
  cd apps-gorm/
  make clean
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..

  showPrompt

  echo -e "${GREEN}Building PDFKit...${NC}"
  cd PDFKit/
  ./configure
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..
  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building GWorkspace...${NC}"
  cd apps-gworkspace/
  make clean
  CC=clang ./configure
  CC=clang make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building SystemPreferences...${NC}"
  cd apps-systempreferences/
  make clean
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..

  sudo ldconfig
fi

if [ "$THEMES" = true ] ; then

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NesedahRik.theme...${NC}"
  cd plugins-themes-nesedahrik/
  sudo cp -R NesedahRik.theme /usr/GNUstep/System/Library/Themes/
  cd ..

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NarcissusRik.theme...${NC}"
  cd plugins-themes-narcissusrik/
  sudo cp -R NarcissusRik.theme /usr/GNUstep/System/Library/Themes/
  cd ..

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing Sombre.theme...${NC}"
  cd plugins-themes-sombre/
  make -j4
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing Rik.theme...${NC}"
  cd rik.theme/
  make -j4
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
  cd ..
fi

echo -e "\n\n"
echo -e "${GREEN}Install is done. Open a new terminal to start using.${NC}"
