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
if [ "$ARCH" = "x86_64" ]; then
    wget https://launchpad.net/~aapo-rantalainen/+archive/ubuntu/games/+files/maniadrive_1.3-+xenial_amd64.deb -O /tmp/app.deb

    mkdir -p ./AppDir/bin
    ar xvf /tmp/app.deb
    tar -xvf ./data.tar.xz -C ./AppDir/bin --strip-components=3 ./opt/maniadrive/
    rm -f ./*.xz
    mv -v ./AppDir/bin/libraydium.so.0 /usr/lib
    ln -sf /usr/lib/libGLEW.so /usr/lib/libGLEW.so.1.13

fi
