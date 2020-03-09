#!/bin/bash
set -x
cd /home/exodusnick/LineageOS/17.1_LineageOS/
make clean
export PATH=~/bin:$PATH
export USE_CCACHE=1
ccache -M 50G
export CCACHE_COMPRESS=1
repo sync --no-clone-bundle --force-sync
source build/envsetup.sh; breakfast hero2lte; time brunch hero2lte
