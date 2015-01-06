#!/bin/bash
# Instalacion de  WordPress  en sistemas Gnu/Linu Debian/Ubuntu
#**********************
#Creado por 0x4171341 *
#**********************
#  correr como root 
if [[ $UID != 0 ]]; then
    echo "Por favor corra este scripts como root:"
    echo "sudo $0 $*"
    exit 1
fi

# set colors
green=`tput setaf 2`
red=`tput setaf 1`
normal=`tput sgr0`
bold=`tput bold`

# start
echo "${normal}${bold}UBUNTU SITE INSTALLER${normal}"
read -p "Installer adds site files to /var/www, are you ready (y/n)? "
[ "$(echo $REPLY | tr [:upper:] [:lower:])" == "y" ] || exit

# Instalacion de WP
read -p "Install WordPress (y/n)? " wpFiles

if [ $wpFiles == "y" ]; then
	read -p "Database name: " dbname
	read -p "Database username: " dbuser

	#Si usted va a utilizar la raíz de preguntar primero
	if [ $dbuser == 'root' ]; then
		read -p "${red} es recomendado no ser root (y/n)?${normal} " useroot

		if [ $useroot == 'n' ]; then
			read -p "Database username: " dbuser
		fi
	else
		useroot='n'
	fi

	read -s -p "Enter a password for user $dbuser: " userpass
	echo " "
# Creaando base de datos MySQL
#read -p "Enter your MySQL root password: " rootpass
#read -p "Database name: " dbname
#read -p "Database username: " dbuser
#read -p "Enter a password for user $dbuser: " userpass
#echo "Creando BASE DE DATO $dbname;" | mysql -u root -p$rootpass
#echo "Creando usuario'$dbuser'@'localhost' IDENTIFiCADO COMO '$userpass';" | mysql -u root -p$rootpass
#echo "GRANT ALL PRIVILEGES ON $dbname.* DE '$bduser'@'localhost';" | mysql -u root -p$rootpass
#echo "FLUSH PRIVILEGES;" | mysql -u root -p$rootpass
#echo "Nueva base de datos creatada"

# Descarga y configura WordPress
read -r -p " Presione enter  para descargar ? [e.g. mywebsite.com]: " wpURL
wget -q -O - "http://wordpress.org/latest.tar.gz" | tar -xzf - -C /var/www --transform s/wordpress/$wpURL/
chown www-data: -R /var/www/$wpURL && cd /var/www/$wpURL
cp wp-config-sample.php wp-config.php
chmod 640 wp-config.php
mkdir uploads
sed -i "s/database_name_here/$dbname/;s/username_here/$dbuser/;s/password_here/$userpass/" wp-config.php

# Creando Apache en servidor virtual
echo "
ServerName $wpURL
ServerAlias www.$wpURL
DocumentRoot /var/www/$wpURL
DirectoryIndex index.php

Options FollowSymLinks
AllowOverride All

ErrorLog ${APACHE_LOG_DIR}/error.log
CustomLog ${APACHE_LOG_DIR}/access.log combined
" > /etc/apache2/sites-available/$wpURL

# Habilitado el sitio
a2ensite $wpURL
service apache2 restart

# Salida
WPVER=$(grep "wp_version = " /var/www/$wpURL/wp-includes/version.php |awk -F\' '{print $2}')
echo -e "\nWordPress version $WPVER fue instalado correctamente!"
echo -en "\aPlease go to http://$wpURL a finalizado la instalacion correctamente\n"
