#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################

echo "so you really wanna delete everything.. well..."

echo "lets just wait 5 seconds to abort (ctrl+c)"

wait 5

echo -e "\e[31mDELETING EVERYTHING OF $1"
if test -f "/etc/nginx/sites-enabled/$1"; then

echo -e "\e[103mDeleting nginx config"
echo -e "\e[47m \e[93m "
rm /etc/nginx/sites-enabled/$1

rm /etc/nginx/sites-available/$1

nginx -s reload
echo -e "\e[105m \e[30m Deleting all files in replacewithwebrootdir/$1 & replacewithmntdir/$1 (did you make a backup?)"

while true; do
    read -p 'do you want to continue "y" or "n": ' yn

    case $yn in

        [Yy]* ) echo 'OK. Deleting all files it is';bash /scripts/deletefiles.sh $1; break;;

        [Nn]* ) echo "Ok, No files. got ya!";break;;

        * ) echo 'Please answer yes or no: ';;

    esac

done


echo -e "\e[105m \e[30m Deleting all logfiles for $1 in replacewithnextcloudlogsdir ?"

while true; do
    read -p 'do you want to continue "y" or "n": ' yn

    case $yn in

        [Yy]* ) echo 'OK. Deleting all log files';bash /scripts/deletelogs.sh $1; break;;

        [Nn]* ) echo "Ok, No Logs. got ya!";break;;

        * ) echo 'Please answer yes or no: ';;

    esac

done

echo -e "\e[105m \e[30m Deleting database & user for $1 ?"

while true; do
    read -p 'do you want to continue "y" or "n": ' yn

    case $yn in

        [Yy]* ) echo 'OK. Deleting the database for $1';bash /scripts/deletedb.sh $1; break;;

        [Nn]* ) echo "Ok, Not the database. got ya!";break;;

        * ) echo 'Please answer yes or no: ';;

    esac

done

rm replacewithscriptsdatadir/$1
rm replacewithsecretsdir/$1

echo -e "\e[42mThats everything. Have a wonderful day! \e[39m \e[49m "

else

	echo "No such file! Aborting!"
fi
