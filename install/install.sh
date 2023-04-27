#!/bin/bash
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################

# This is just another excuse to not write an ansible role cause it is soo much easier for you to setup. (Yes I'll show myself to the door....)

# the whole setup assumes that the user you're using is root. If this isn't the case, well. Search for another script or alter it the way you want. (If it comes out nice, feel free to create a MR)
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root" 
   exit 1
fi

# Update & Upgrade the System
apt update && apt upgrade -y

# Install all the stuff you need
apt install nginx certbot wget unzip bash sed python3-certbot-nginx mariadb-server php8.1 php8.1-cli php8.1-intl php8.1-fpm php8.1-zip php8.1-mysql php8.1-opcache php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl libmagickcore-6.q16-3-extra php8.1-imagick -y

# copy the nginx config snippets that we need
cp /scripts/install/src/immutable.conf /etc/nginx/conf.d/immutable.conf
cp /scripts/install/src/php-handler.conf /etc/nginx/conf.d/php-handler.conf

# test the nginx config
nginx -t

# PHP Config
# Remove the lines with the content we want to replace
sed -i "/post_max_size/d" /etc/php/8.1/fpm/php.ini
sed -i "/memory_limit/d" /etc/php/8.1/fpm/php.ini
sed -i "/upload_max_filesize/d" /etc/php/8.1/fpm/php.ini

# Set the new Values
echo "upload_max_filesize = 512M" >> /etc/php/8.1/fpm/php.ini
echo "memory_limit = 1024M" >> /etc/php/8.1/fpm/php.ini
echo "post_max_size = 512M" >> /etc/php/8.1/fpm/php.ini

# create this directory
mkdir /scripts/data

# create the ncmgmt command and source the .bashrc to have it ready
echo 'alias ncmgmt="bash /scripts/domainmgmt.sh"' >> ~/.bashrc
source ~/.bashrc

# enter your custom subdomain. If you don't use that part this is the point where you can Ctrl+C out of this shit.
read -p "Enter your custom subdomain:  " subdomain

# copy the templates into the production paths
cp /scripts/install/src/subdomain.tmpl /scripts/templates/subdomain
cp /scripts/install/src/creation_sub.sh.tmpl /scripts/creation_sub.sh

# replace the template with the production values
sed -i "s/replacewithactualsubdomain/$subdomain/g" /scripts/creation_sub.sh
sed -i "s/replacewithactualsubdomain/$subdomain/g" /scripts/templates/subdomain

# a little note regarding the wildcard certificate
echo "I'll just expect that your wildcard certificate is here: /etc/letsencrypt/live/$subdomain/"
echo " "
echo "If not. You wanna change that in /scripts/templates/subdomain"
