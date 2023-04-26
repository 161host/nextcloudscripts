#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################


echo -e "\e[38;5;82mLets delete the database! \e[39m \e[49m "

echo "Please check if the following customer ID is the correct one for the domain $1 !!!"

cat /scripts/data/$1

echo "To confirm. Please enter (or copy) the customer ID from above here:"

read -p "Enter the Customer ID:  " custid

if [ "$(cat /scripts/data/$1)" != "$custid" ]; then
    echo "Customer ID doesn't match! Abort!"
    exit 1
fi

echo "Customer ID matches. Going ahead and deleting the database!"

dbname=nextcloud_$custid
dbuser="${dbname}_usr"

mysql -e "DROP DATABASE ${dbname};"
mysql -e "DROP USER '${dbuser}'@'localhost';"

# Cause I don't want to load the customer ID somewhere else, I'll load it here.
sed -i "/occ_$custid/d" ~/.bashrc