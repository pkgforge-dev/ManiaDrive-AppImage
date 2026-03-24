#!/bin/sh

set -eu

ARCH=$(uname -m)

echo "Installing package dependencies..."
echo "---------------------------------------------------------------"
pacman -Syu --noconfirm \
    freealut       \
    glew           \
    glu            \
    libxml2-legacy \
    libcurl-gnutls \
    v4l-utils

echo "Installing debloated packages..."
echo "---------------------------------------------------------------"
get-debloated-pkgs --add-common --prefer-nano

# Comment this out if you need an AUR package
make-aur-package libpng12

# If the application needs to be manually built that has to be done down here
mkdir -p ./AppDir/bin
if [ "$ARCH" = "x86_64" ]; then
    wget https://launchpad.net/~aapo-rantalainen/+archive/ubuntu/games/+files/maniadrive_1.3-+xenial_amd64.deb -O /tmp/app.deb
    ar xvf /tmp/app.deb
    tar -xvf ./data.tar.xz -C ./AppDir/bin --strip-components=3 ./opt/maniadrive/
    rm -f ./*.xz
    mv -v ./AppDir/bin/libraydium.so.0 /usr/lib
    ln -sf /usr/lib/libGLEW.so /usr/lib/libGLEW.so.1.13
else
    wget https://launchpad.net/~aapo-rantalainen/+archive/ubuntu/games/+sourcefiles/maniadrive/1.3-+xenial/maniadrive_1.3-+xenial.tar.gz
    mkdir mania_src
    tar -xvf maniadrive_1.3-+xenial.tar.gz --strip-components=1 -C mania_src
    cd mania_src
    export LIBXML_CFLAGS="-I/usr/lib/libxml2-legacy/include/libxml2"
    export LIBXML_LIBS="-L/usr/lib/libxml2-legacy/lib -lxml2"
    export PKG_CONFIG_PATH="/usr/lib/libxml2-legacy/lib/pkgconfig"
    CFLAGS="-fcommon -std=gnu89" ./configure --disable-x
    patch 
    patch 
    DISABLE_AUTORUN=1 ./odyncomp.sh mania_drive.c
    #make -j$(nproc)
fi
