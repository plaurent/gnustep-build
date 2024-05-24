#!/bin/bash

## Script to install the newest available version of GNUstep on Debian stable (buster)

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
export PATH=/usr/GNUstep/System/Tools/:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
export RUNTIME_VERSION=gnustep-2.0
export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig
export LD=/usr/bin/ld.gold
export LDFLAGS="-fuse-ld=/usr/bin/ld.gold"
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
  cd ../make
  make clean
  ./configure \
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

# Install Requirements
echo -e "\n\n${GREEN}Installing dependencies...${NC}"

echo "deb http://deb.debian.org/debian buster-backports main" | sudo tee /etc/apt/sources.list.d/backports.list
sudo apt-get update
sudo apt -y remove clang cmake

DEBIAN_FRONTEND=noninteractive sudo apt -y install clang build-essential git subversion cmake \
libc6 libc6-dev \
libxml2 libxml2-dev \
libffi8 libffi-dev \
libicu-dev icu-devtools \
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
python3-dev swig \
libreadline8 libreadline-dev \
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
libgif7 libgif-dev libwings3 libwings-dev \
libwraster-dev libwutil5 \
libcups2-dev \
xorg \
libfreetype6 libfreetype6-dev \
libpango1.0-dev \
libcairo2-dev \
libxt-dev libssl-dev \
libasound2-dev libjack-dev libjack0 libportaudio2 \
libportaudiocpp0 portaudio19-dev \
xpdf libxrandr-dev

if [ "$APPS" = true ] ; then
  sudo apt -y install curl
fi

# Create build directory
mkdir GNUstep-build
cd GNUstep-build

# Checkout sources
echo -e "\n\n${GREEN}Checking out sources...${NC}"
git clone https://github.com/apple/swift-corelibs-libdispatch
# cd swift-corelibs-libdispatch
#   git checkout swift-5.3.3-RELEASE
# cd ..

git clone https://github.com/gnustep/make
git clone https://github.com/gnustep/libobjc2.git
cd libobjc2
  git checkout 2.1
  git submodule init
  git submodule sync
  git submodule update
cd ..
git clone https://github.com/gnustep/base
#git clone https://github.com/gnustep/corebase
git clone https://github.com/gnustep/gui
git clone https://github.com/gnustep/back

if [ "$APPS" = true ] ; then
  git clone https://github.com/gnustep/apps-projectcenter.git
  git clone https://github.com/gnustep/apps-gorm.git
  svn co http://svn.savannah.nongnu.org/svn/gap/trunk/libs/PDFKit/
  git clone https://github.com/gnustep/apps-gworkspace.git
  git clone https://github.com/gnustep/apps-systempreferences.git
fi

if [ "$THEMES" = true ] ; then
  git clone https://github.com/BertrandDekoninck/NarcissusRik.git
  git clone https://github.com/BertrandDekoninck/NesedahRik.git
fi

showPrompt

cd make
installGNUstepMake

showPrompt

echo $LDFLAGS
echo $OBJCFLAGS
. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh
echo $LDFLAGS
echo $OBJCFLAGS
echo "export PATH=/usr/GNUstep/System/Tools:/usr/GNUstep/System/Tools:$PATH" >> ~/.bashrc
echo "export RUNTIME_VERSION=$RUNTIME_VERSION" >> ~/.bashrc
echo "export LD=/usr/bin/ld.gold" >> ~/.bashrc
echo "export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/GNUstep/System/Library/Libraries/" >> ~/.bashrc
echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> ~/.bashrc

## Build libDispatch
echo -e "\n\n"
echo -e "${GREEN}Building libdispatch...${NC}"
cd ../swift-corelibs-libdispatch
rm -Rf build
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=RelWithDebInfo \
	 -DCMAKE_SKIP_RPATH=ON \
	 -DCMAKE_BUILD_TYPE='None' \
	 -DCMAKE_INSTALL_PREFIX=/usr/GNUstep \
	 -DCMAKE_INSTALL_LIBDIR=/usr/GNUstep/System/Library/Libraries/ \
	 -DCMAKE_INSTALL_MANDIR=/usr/GNUstep/System/Library/Documentation/man/ \
	 -DINSTALL_DISPATCH_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/dispatch \
	 -DINSTALL_BLOCK_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/block \
	 -DINSTALL_OS_HEADERS_DIR=/usr/GNUstep/System/Library/Headers/os \
	 -DINSTALL_PRIVATE_HEADERS=YES
make
sudo -E make install
sudo rm /usr/GNUstep/System/Library/Headers/block/Block.h
sudo rm /usr/GNUstep/System/Library/Headers/block/Block_private.h
sudo ldconfig

showPrompt

# Build libobjc2
echo -e "\n\n"
echo -e "${GREEN}Building libobjc2...${NC}"
cd ../../libobjc2
rm -Rf build
mkdir build && cd build
cmake .. -DBUILD_STATIC_LIBOBJC=1 \
	-DGNUSTEP_INSTALL_TYPE='SYSTEM' \
	-DCMAKE_BUILD_TYPE='Release' \
	-DCMAKE_LIBRARY_PATH=/usr/lib \
	-DCMAKE_INSTALL_PREFIX=/usr/GNUstep \
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
./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
sudo ldconfig

showPrompt

# Build GNUstep corebase
#echo -e "\n\n"
#echo -e "${GREEN}Building GNUstep corebase...${NC}"
#cd ../corebase
#make clean
#./configure
#make -j8
#sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
#sudo ldconfig

#showPrompt

# Build GNUstep GUI
echo -e "\n\n"
echo -e "${GREEN} Building GNUstep-gui...${NC}"
cd ../gui
make clean
./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
sudo ldconfig

showPrompt

# Build GNUstep back
echo -e "\n\n"
echo -e "${GREEN}Building GNUstep-back...${NC}"
cd ../back
make clean
./configure
make -j8
sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install
sudo ldconfig

showPrompt

. /usr/GNUstep/System/Library/Makefiles/GNUstep.sh

export LDFLAGS="-fuse-ld=/usr/bin/ld.gold"
sudo ldconfig

installGNUstepMake
if [ "$APPS" = true ] ; then
  echo -e "${GREEN}Building ProjectCenter...${NC}"
  cd ../apps-projectcenter/
  make clean
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install

  showPrompt

  echo -e "${GREEN}Building Gorm...${NC}"
  cd ../apps-gorm/
  make clean
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install

  showPrompt

  echo -e "${GREEN}Building PDFKit...${NC}"
  cd ../PDFKit/
  ./configure
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building GWorkspace...${NC}"
  cd ../apps-gworkspace/
  make clean
  ./configure
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Building SystemPreferences...${NC}"
  cd ../apps-systempreferences/
  make clean
  make -j8
  sudo -E make GNUSTEP_INSTALLATION_DOMAIN=SYSTEM install

  sudo ldconfig
fi

if [ "$THEMES" = true ] ; then

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NesedahRik.theme...${NC}"
  cd ../NesedahRik/
  sudo cp -R NesedahRik.theme /usr/GNUstep/System/Library/Themes/

  showPrompt

  echo -e "\n\n"
  echo -e "${GREEN}Installing NarcissusRik.theme...${NC}"
  cd ../NarcissusRik/
  sudo cp -R NarcissusRik.theme /usr/GNUstep/System/Library/Themes/

fi

echo -e "\n\n"
echo -e "${GREEN}Install is done. Open a new terminal to start using.${NC}"
