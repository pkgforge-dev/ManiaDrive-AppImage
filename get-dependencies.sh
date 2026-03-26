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
#if [ "$ARCH" = "x86_64" ]; then
wget https://launchpad.net/~aapo-rantalainen/+archive/ubuntu/games/+sourcefiles/maniadrive/1.3-+xenial/maniadrive_1.3-+xenial.tar.gz
mkdir mania_src
tar -xvf maniadrive_1.3-+xenial.tar.gz
cd maniadrive-1.3
export LIBXML_CFLAGS="-I/usr/lib/libxml2-legacy/include/libxml2"
export LIBXML_LIBS="-L/usr/lib/libxml2-legacy/lib -lxml2"
export PKG_CONFIG_PATH="/usr/lib/libxml2-legacy/lib/pkgconfig"
if [ "$ARCH" = "aarch64" ]; then
    CFLAGS="-fcommon -std=gnu89" ./configure --disable-x--disable-x86-asm
else
    CFLAGS="-fcommon -std=gnu89" ./configure --disable-x
fi
patch -Ni kids_mode.patch
patch -Ni editor_start.patch
sed -i 's/^CFLAGS = -Wall -Wno-unused-result/& -fcommon/' Makefile
sed -i 's/^LDFLAGS=/& -L\/usr\/lib\/libxml2-legacy\/lib -lxml2/' Makefile
DISABLE_AUTORUN=1 ./odyncomp.sh mania_drive.c
mv -v test ../AppDir/bin/mania.bin
DISABLE_AUTORUN=1 ./odyncomp.sh mania2.c
mv -v test ../AppDir/bin/level_editor.bin
mv -v *.php mania_drive.story.beg mania_drive.story.pro ../AppDir/bin
mv -v libraydium.so.0.0 /usr/lib/libraydium.so.0
rm -f rayphp/README
rm -f rayphp/r3s/README
mv -v rayphp ../AppDir/bin
