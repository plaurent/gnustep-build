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
APPS=true

# Set to true to also build and install GNUstep themes
THEMES=true

# Set to true to pause after each build to verify successful build and installation
PROMPT=false

# Install Requirements
sudo apt update

echo -e "\n\n${GREEN}Installing dependencies...${NC}"

sudo apt-get update
sudo apt -y install clang build-essential git subversion \
libxml2 libxml2-dev \
libffi8 libffi-dev \
libuuid1 uuid-dev uuid-runtime \
libsctp1 libsctp-dev lksctp-tools \
libavahi-core7 libavahi-core-dev \
libavahi-client3 libavahi-client-dev \
libavahi-common3 libavahi-common-dev libavahi-common-data \
libgcrypt20 libgcrypt20-dev \
libtiff6 libtiff5-dev \
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
python-dev-is-python3 swig \
libedit-dev libedit2 libeditreadline-dev \
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
libstdc++-11-dev \
gobjc-11 gobjc++-11 \
gobjc++ \
libgif7 libgif-dev libwings3 libwings-dev libwutil5 \
libcups2-dev \
xorg \
libfreetype6 libfreetype6-dev \
libpango1.0-dev \
libcairo2-dev \
libxt-dev libssl-dev \
libasound2-dev libjack-dev libjack0 libportaudio2 \
libportaudiocpp0 portaudio19-dev \
libstdc++-11-doc libstdc++-11-pic \
cmake xpdf libxrandr-dev

if [ "$APPS" = true ] ; then
  sudo apt -y install curl
fi

# Create build directory
mkdir GNUstep-build
cd GNUstep-build

# Set clang as compiler
export CC=clang
export CXX=clang++
export RUNTIME_VERSION=gnustep-2.1
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export LD=/usr/bin/ld.gold
export LDFLAGS="-fuse-ld=gold -L/usr/local/lib"


# Checkout sources
echo -e "\n\n${GREEN}Checking out sources...${NC}"
git clone https://github.com/apple/swift-corelibs-libdispatch

git clone https://github.com/gnustep/libobjc2.git
cd libobjc2
  git submodule init && git submodule update
cd ..
git clone https://github.com/gnustep/tools-make.git
git clone https://github.com/gnustep/libs-base.git
git clone https://github.com/gnustep/libs-corebase.git
git clone https://github.com/gnustep/libs-gui.git
git clone https://github.com/gnustep/libs-back.git

if [ "$APPS" = true ] ; then
  git clone https://github.com/gnustep/apps-projectcenter.git
  git clone https://github.com/gnustep/apps-gorm.git
  wget http://savannah.nongnu.org/download/gap/PDFKit-1.2.0.tar.gz
  git clone https://github.com/gnustep/apps-gworkspace.git
  git clone https://github.com/gnustep/apps-systempreferences.git
fi

if [ "$THEMES" = true ] ; then
  git clone https://github.com/BertrandDekoninck/NarcissusRik.git
  git clone https://github.com/BertrandDekoninck/NesedahRik.git
  git clone https://github.com/BertrandDekoninck/rik.theme.git
fi

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
	-DCMAKE_BUILD_TYPE=Release
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
cmake ../ -DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_ASM_COMPILER=clang -DTESTS=OFF
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

# Build GNUstep base
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-base...${NC}"
cd ../libs-base/
./configure
make -j8
sudo -E make install

showPrompt

# Build GNUstep GUI
echo -e "\n\n"
echo -e "${GREEN} Building GNUstep-gui...${NC}"
cd ../libs-gui
./configure
make -j8
sudo -E make install

showPrompt

# Build GNUstep back
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-back...${NC}"
cd ../libs-back
./configure
make -j8
sudo -E make install

showPrompt

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

if [ "$APPS" = true ] ; then
  echo -e "${GREEN}Building ProjectCenter...${NC}"
  cd ../apps-projectcenter/
  make -j8
  sudo -E make install

  showPrompt

  echo -e "${GREEN}Building Gorm...${NC}"
  cd ../apps-gorm/
  make -j8
  sudo -E make install

  showPrompt

  echo -e "${GREEN}Building PDFKit...${NC}"
  cd ..
  tar xzf PDFKit-1.2.0.tar.gz
  cd PDFKit-1.2.0
  ./configure
  make -j8
  sudo -E make install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building GWorkspace...${NC}"
  cd ../apps-gworkspace/
  ./configure
  make -j8
  sudo -E make install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building SystemPreferences...${NC}"
  cd ../apps-systempreferences/
  make -j8
  sudo -E make install

fi

if [ "$THEMES" = true ] ; then
  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Not Building rik.theme...${NC}"
  # cd ../rik.theme/
  # make clean
  # make -j8
  # sudo -E make install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NesedahRik.theme...${NC}"
  cd ../NesedahRik/
  sudo cp -R NesedahRik.theme /usr/GNUstep/Local/Library/Themes/

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NesedahRik.theme...${NC}"
  cd ../NesedahRik/
  sudo cp -R NesedahRik.theme /usr/GNUstep/Local/Library/Themes/
fi

echo -e "\n\n"
echo -e "${GREEN}Install is done. Open a new terminal to start using.${NC}"
