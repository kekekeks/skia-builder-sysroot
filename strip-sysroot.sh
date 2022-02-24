#!/bin/bash

SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
set -e
set -x
SRC="$1"
DST="$2"

rm -rf $DST
mkdir -p $DST/usr/lib
mkdir -p $DST/lib
#cp -Ra $SRC/usr/include $DST/usr

#cp -Ra $SRC/usr/lib/gcc $DST/usr/lib


#cp -Ra $SRC/lib $DST
#cp -Ra $SRC/usr/lib $DST/usr
#rm -rf $DST/usr/lib/systemd
#rm -rf $DST/lib/systemd

TMP=$DST/tmp
mkdir -p $TMP/usr
cp -R $SRC/lib $TMP
cp -R $SRC/usr/{lib,include} $TMP/usr
rm -rf $TMP/lib/systemd
python $SCRIPTPATH/fix_links.py $DST/tmp

FLAVOR=`ls $TMP/usr/lib|egrep -o '[^/]+-linux-[^/]+'`
echo Flavor: $FLAVOR
mkdir $DST/usr/lib/$FLAVOR $DST/lib/$FLAVOR
cp -Ra $TMP/usr/include $DST/usr
cp -Ra $TMP/usr/lib/gcc $DST/usr/lib
cp -Ra $TMP/usr/lib/$FLAVOR/{libfontc*so*,libc.so*,libm.so*,libpthread*,libdl.so*,*.o,*.a} $DST/usr/lib/$FLAVOR
cp -Ra $TMP/lib/*-linux-*/{libc-*,libc.so*,libm-*,libm.so*,libdl.so*,libdl-*,libpth*,libgcc*,ld-*} $DST/lib/$FLAVOR




rm -rf $TMP

