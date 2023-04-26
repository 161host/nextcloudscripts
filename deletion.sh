#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################

echo "deleting"
echo " "
echo " "
read -p "Enter the Domain Name you want to delete:  " domainname

echo -e " \e[101m Do you really want to delete $domainname ?! "
while true; do
    read -p '"y" or "n": ' yn

    case $yn in

        [Yy]* ) echo "OK";bash /scripts/reallydelete.sh $domainname; exit;;

        [Nn]* ) echo "Aborting!"; break;;

        * ) echo 'Please answer y or n: ';;

    esac

done

echo -e " \e[45mAborted. Bye \e[39m"