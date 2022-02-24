#!/bin/bash
SCRIPTPATH="$( cd -- "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
set -x
set -e

mkdir -p opts.gen
cd skia



function prepare {
  python2 tools/git-sync-deps
}

function run_gn
{
  NAME=$1
  SYSROOT=$2
  cp ../opts/$NAME ../opts.gen/$NAME
  SYSROOT=`echo -n $SYSROOT|sed 's/\//\\\\\//g'`
  WINLLVM=`echo -n $WINLLVM|sed 's/\//\\\\\//g'`
  sed -i "s/\$SYSROOT/$SYSROOT/g" ../opts.gen/$NAME
  sed -i "s/\$WINLLVM/$WINLLVM/g" ../opts.gen/$NAME
  bin/gn gen out/$NAME --args="`cat ../opts.gen/$NAME`"
  ninja -C out/$NAME skia
}

#prepare

#run_gn linux-glibc-armhf $SYSROOTS/stretch-armhf
#run_gn linux-glibc-arm64 $SYSROOTS/stretch-arm64
#run_gn linux-glibc-amd64 $SYSROOTS/stretch-amd64
WINLLVM=$SCRIPTPATH/llvm-win-amd64 PATH=$MINGWLLVM/bin:$PATH run_gn windows-msvcrt-amd64 ""


