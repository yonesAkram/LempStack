#!/bin/bash

echo " Hello, Welcome to my bash script to install LEMP Stack \n This Script meant to install Nginx, PHP, MariaDB to Host website for Register and login "

#Install Required Packages

sudo apt update

sudo apt install nginx mariadb-server mariadb-client php8.1 php8.1-fpm php8.1-mysql php-common php8.1-cli php8.1-common php8.1-opcache php8.1-readline php8.1-mbstring php8.1-xml php8.1-gd php8.1-curl -y

#Configure Firewall Utility UFW

sudo ufw enable

sudo ufw allow 80 

sudo ufw allow 443

sudo ufw allow 'Nginx Full'

sudo ufw allow 3306

sudo ufw reload

#Start and enable required services

sudo systemctl start nginx mariadb php8.1-fpm

sudo systemctl enable nginx mariadb php8.1-fpm

#Nginx necessary configurations

read -p " please enter website name you want to install " website

sudo mkdir -p /var/www/$website

sudo cp -r /home/abdelrahman/html /var/www/$website/

sudo chown -R www-data:$USER /var/www/$website/html/

sudo touch /etc/nginx/sites-available/$website

sudo chmod 777 /etc/nginx/sites-available/$website

sudo cat /home/abdelrahman/serverblock > /etc/nginx/sites-available/$website

sudo ln -s /etc/nginx/sites-available/$website /etc/nginx/sites-enabled/

sudo nginx -t

sudo systemctl reload nginx

#Database install

sudo mysql_secure_installation

# Prompt for MySQL/MariaDB user credentials and table name
read -p "Enter MySQL/MariaDB username: " dbuser
read -sp "Enter MySQL/MariaDB password: " dbpassword
read -p "Enter database name: " dbname
read -p "Enter table name: " tablename

sudo mysql -u root <<MYSQL_SCRIPT

# Create a new database
CREATE DATABASE IF NOT EXISTS $dbname;

# Create a new user and grant privileges
CREATE USER '$dbuser'@'localhost' IDENTIFIED BY '$dbpassword';
GRANT ALL PRIVILEGES ON $dbname.* TO '$dbuser'@'localhost' WITH GRANT OPTION;

# Exit from the MySQL prompt
FLUSH PRIVILEGES;
exit
MYSQL_SCRIPT

# Create a SQL file to create the table with the provided table name
echo "CREATE TABLE IF NOT EXISTS $tablename (
    username VARCHAR(50),
    password VARCHAR(100),
    category VARCHAR(50)
);" > create_table.sql

# Log into MariaDB using the provided credentials and execute the SQL file
mysql -u "$dbuser" -p"$dbpassword" "$dbname" < create_table.sql

# Clean up SQL file
rm create_table.sql

echo "Table $tablename created successfully in database $dbname."