#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################


echo -e "\e[38;5;82mLets delete some files! \e[39m \e[49m "


rm -rf /webroot/$1
rm -rf /data/$1

echo "success"