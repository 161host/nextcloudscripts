Nextcloud Install Scripts
===

`Heads up: This is a lot of rambling because I suck at writing README's.. If you can do it better, feel free to create a PR`

# Quickstart

```bash
git clone https://github.com/161host/nextcloudscripts /scripts
bash /scripts/install/install.sh
```

# README
These files allow you to install multiple nextclouds on the same host without docker and stuff.


```
###################################################
# Author: Thies Mueller (https://thiesmueller.de) #
# License: GNU AGPL v3.0                          #
# USE AT YOUR OWN RISK!                           #
# Originally developed for 161host.net            #
###################################################
```

**If you use this software commercially please link to this repository and/or 161host.net / me**

**This software is NOT for Nazis, (Alt-)Rights, TERFs, the military, weapons & defense manufactures, and stuff like that.**

If you go to https://161host.net and are offended **THIS TOOL IS NOT FOR YOU!**

![](install/antifa.png)


## Motivation

I wanted to easily create multiple nextcloud instances for customers of 161host.net

All the other stuff is based on multiple docker containers and because I thought it'll be a waste of ressources I decided to build it as bash scripts directly running on a webserver.

A feew weeks ago someone asked me how he could do something similar, so I decided to publish this hunk of junk.

It's a pile of bash scripts, so don't expect anything fancy.



## How to use

### Prerequirements

- Host running some Linux OS of your choice (Tested with Ubuntu 22.04)
- Public IPv4 and/or Public IPv6 (If you wan't to use the Let's Encrypt certs)
- Internet Connection

### Software Needed

- wget
- bash (NO! NOT `SH`! NOT `ZSH`! NOT `FISH`! `BASH`! (maybe it'll work with other stuff but don't cry about it if something breaks...))
- unzip
- sed
- nginx
- certbot
- python3-certbot-nginx
- mariadb-server
- libmagickcore-6.q16-3-extra
- php8.1
- php8.1-cli
- php8.1-fpm
- php8.1-zip
- php8.1-mysql
- php8.1-opcache
- php8.1-mbstring
- php8.1-xml
- php8.1-gd
- php8.1-curl
- php8.1-intl
- php8.1-imagick

**This scrips expect some stuff. Alter them as needed if your setup differs from mine.**

### Directories

The installation is split in multiple directories.

This is first and foremost to have the possibility to split the stuff onto multiple volumes.

The below mentioned directories are the default.

i.e. `/webroot` on a high i/o volume for smooth usage of the webapps and stuff but `/data` on a slower volume cause high i/o volumes are still not that cheap or `/secrets` in a specially encrypted volume that needs to be mounted before the script is run

- `/webroot` This is the directory where the nextcloud installation lands
- `/data` This is the directory where the nextcloud userdata lands
- `/scripts` This is the directory where the scripts expect to sit and wait for you
- `/secrets` This is the directory where the credentials will be dropped as a plaintext file for you to read, copy over to a password manager and afterwards **DELETE**
- `/var/log/nextcloud` This is the log directory


### Getting started

*Here I'll expect you already have `git` installed on your system. If not do that now.*


If you don't want to do the mounting stuff yourself you can just run the installer

I'm no fan of `curl https://<something> | bash` as root so here we go. Here is what most of these files are:

```bash
git clone https://github.com/161host/nextcloudscripts /scripts
bash /scripts/install/install.sh
```



**The `install.sh` will fail if you don't have a Debian based OS and most likely will fail if your system doesn't know how to get php8.1!**

You can also look at the `install.sh` file and do the steps yourself if you don't trust me. (Good for you. You don't know me and I'm just a stranger from the interwebz...) I've tried to keep it as simple as possible.

Also the install won't generate a wildcard certificate for you cause I can't be bothered to write a script that asks you like 1000 questions just to find out that whatever DNS provider you're using has no API for certbot or something like that. If you want to use that get a wildcard before.

Worst case do it manually with (and replace domain & email ;) )

```bash
certbot certonly --manual --preferred-challenges=dns --email valid@example.com --server https://acme-v02.api.letsencrypt.org/directory --agree-tos -d nc.example.com -d *.nc.example.com
````

### How to create a new Nextcloud Instance with the script

- `ncmgmt`
  - You should see something like `Create subdomain (s) , own Domain (o) or delete Domain (d)?:`
- Select s or o 
- Enter the subdomain part (s) or the fqdn (o)
- Enter the customer ID (this needs to be a unique string only containing lowercase letters and numbers. Everything else will break stuff later! **I'LL EXPRESS THE _UNIQUE_ PART AGAIN CAUSE OTHERWISE YOU'LL LOOSE DATABASES!**)
- The auto installer will download the latest.zip from nextcloud will unzip it into the right directory and set some stuff via `occ` (the nextcloud command line tool)
- The auto install will present you with the contents of `/secrets/$fqdn` use them to test and **PLEASE** delete it after you put the credentials in a safer place ( i.e. password manager )

### How to delete a Nextcloud Instance

- `ncmgmt`
- Select `d`
- Enter the domain you want to delete
- Confirm with `y` that the thing you typed is actually the instance you want to delete
- Decide if you want to delete everything from the `/data/$fqdn` & `/webroot/$fqdn` folder with y/n
- Decide if you want to delete all logs for the instance with y/n
- Decide if you want to delete the DB and the user with y/n **If you don't delete the DB & User you can't reuse the customer ID used for this instance as this will lead to corrupted nextcloud instances!**
- If you've decided to delete the DB you'll be asked to input the customer ID. This is to double check with you if that's the right DB that'll be deleted.
- Done. The Nextcloud is now gone.
