#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################


echo -e "\e[38;5;82mLets delete some logs! \e[39m \e[49m "


rm  replacewithnextcloudlogsdir/$1*

echo "success"