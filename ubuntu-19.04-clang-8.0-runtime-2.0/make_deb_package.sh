#!/bin/bash

# Script to build a GNUstep package based on what is built in gnustep-build
# 
# To install GNUstep on your system using the resulting package, you can do:
#   sudo dpkg -i gnustep-binary_1.0-1.deb
#   sudo apt install -f  # To get all the dependencies
# Then follow the instructions to set up your path and environment variables.

PACKAGE_NAME="gnustep-binary"
VERSION_CODE="1.0-1"

echo "Creating GNUstep Binary Package ${PACKAGE_NAME}_${VERSION_CODE}.deb"

mkdir -p /${PACKAGE_NAME}_${VERSION_CODE}
cd /${PACKAGE_NAME}_${VERSION_CODE}
mkdir -p DEBIAN

cat > DEBIAN/control << EOF
Package: ${PACKAGE_NAME}
Version: ${VERSION_CODE}
Section: base
Priority: optional
Architecture: amd64
Depends: clang, git, cmake, libffi-dev, libxml2-dev, libgnutls28-dev, libicu-dev, libblocksruntime-dev, libkqueue-dev, libpthread-workqueue-dev, autoconf, libtool, libjpeg-dev, libtiff-dev, libffi-dev, libcairo-dev, libx11-dev:i386, libxt-dev, libxft-dev
Maintainer: Patryk Laurent <patryk@pakl.net>
Description: GNUstep Developer and Runtime Distribution
 This package supports running and developing GNUstep applications.
EOF

cat > DEBIAN/preinst << EOF
#!/bin/bash
sudo dpkg --add-architecture i386  # Enable 32-bit repos for libx11-dev:i386
sudo apt update
EOF
chmod +x DEBIAN/preinst

cat > DEBIAN/postinst << EOF
#!/bin/bash
echo " -------------[ GNUstep Final Installation Steps ]-------------------------------"
echo "| Adding the following 2 lines to system-wide bashrc (/etc/bash.bashrc).         |"
echo "| Open a new terminal, launch bash again, or source that script to use GNUstep.  |"
echo "| . /usr/GNUstep/System/Library/Makefiles/GNUstep.sh                             |"
echo "| export RUNTIME_VERSION=gnustep-2.0                                             |"
echo " --------------------------------------------------------------------------------"

echo ". /usr/GNUstep/System/Library/Makefiles/GNUstep.sh" >> /etc/bash.bashrc
echo "export RUNTIME_VERSION=gnustep-2.0" >> /etc/bash.bashrc
EOF
chmod +x DEBIAN/postinst


echo "Copy /usr/GNUstep directory tree."
mkdir -p usr
cd usr
cp -r /usr/GNUstep .
cd ../../

cd /GNUstep-build/libdispatch/build
make install | sed 's/-- //' | sed 's/Creating symlink //' | sed 's/Up-to-date: //'  | grep -v Built | grep -v Install > LIBDISPATCH_INSTALLED_FILES.txt
echo "Copy libdispatch using tar (please ignore tar leading-/ warning.)"
tar -cf LIBDISPATCH_INSTALLED_FILES.tar --files-from LIBDISPATCH_INSTALLED_FILES.txt
mv LIBDISPATCH_INSTALLED_FILES.tar /
cd /${PACKAGE_NAME}_${VERSION_CODE}
tar -xf /LIBDISPATCH_INSTALLED_FILES.tar
cd /
dpkg-deb --build ${PACKAGE_NAME}_${VERSION_CODE}

echo "To install on a new Ubuntu system, use "
echo " sudo dpkg -i ${PACKAGE_NAME}_${VERSION_CODE}.deb"
echo " sudo apt install -f"
echo "Then follow the instructions for your .bashrc and environment variables."
