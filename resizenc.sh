#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################

currentsize="$(ls -lh replacewithdatadir/$domainname | awk '{print  $5}')"
echo "resize nextcloud script"
echo " "
echo " "
read -p "Enter the Domain you want to create:  " domainname
echo "current size of nextcloud: $currentsize"
read -p "New Size of Nextcloud (i.e. 10G) (needs to be larger then $currentsize):   " ncsize


# Some facts:

fqdn="${domainname}"
fsdir="replacewithdatadir/$fqdn"
truncate -s $ncsize $fsdir
resize2fs $fsdir


echo -e " \e[102mGoodbye! \e[0m"
