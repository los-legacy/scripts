#!/bin/bash
set -x
cd /home/exodusnick/LineageOS/17.1_LineageOS/
make clean
export PATH=~/bin:$PATH
repo sync --no-clone-bundle --force-sync
source build/envsetup.sh && breakfast herolte && time brunch herolte
