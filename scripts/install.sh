#!/bin/bash -eux

echo "==> waiting for cloud-init to finish"
while [ ! -f /var/lib/cloud/instance/boot-finished ]; do
    echo 'Waiting for Cloud-Init...'
    sleep 1
done

echo "==> updating apt cache"
sudo apt update -qq

echo "==> upgrade apt packages"
sudo apt upgrade -y -qq

echo "==> installing qemu-guest-agent"
sudo apt install -y -qq qemu-guest-agent

echo "==> setting up UFW to allow for ports 22, 80, 443"
yes | sudo ufw enable
sudo ufw allow 80
sudo ufw allow 443
sudo ufw allow 22
sudo ufw status verbose

echo "==> setting up SSH banner"
#sudo -u www-data sed -i "s/database_name_here/$WORDPRESS_DB/" "/srv/www/wordpress/wp-config.php"
sudo sed -i 's|#Banner none|Banner /etc/ssh_banner|' '/etc/ssh/sshd_config'
sudo echo "Welcome to Application Wordpress" > /etc/ssh_banner

echo "==> installing Apache and MySQL"
sudo apt install apache2 -y
sudo apt install mysql-server -y

echo "==> installing PHP and dependencies"
sudo apt install php libapache2-mod-php php-mysql php-curl php-gd \
php-mbstring php-xml php-xmlrpc php-soap php-intl php-zip -y

#sudo systemctl restart apache2

echo "==> creating database and user for WordPress"
WORDPRESS_DB="wordpress"
WORDPRESS_USER="wordpress"
WORDPRESS_PASS="wordpress"

sudo mysql <<EOF
CREATE DATABASE $WORDPRESS_DB;
CREATE USER '$WORDPRESS_USER'@'localhost' IDENTIFIED WITH mysql_native_password BY '$WORDPRESS_PASS';
GRANT ALL ON $WORDPRESS_DB.* TO '$WORDPRESS_USER'@'localhost'; 
FLUSH PRIVILEGES;
EOF

echo "==> installing WordPress"
sudo mkdir -p /srv/www
sudo chown www-data: /srv/www
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www 

echo "==> configure apache for WordPress"
sudo touch /etc/apache2/sites-available/wordpress.conf
cat <<EOF > /etc/apache2/sites-available/wordpress.conf
<VirtualHost *:443>
   DocumentRoot /srv/www/wordpress

   SSLEngine on
   SSLCertificateFile /etc/ssl/certs/apache-selfsigned.crt
   SSLCertificateKeyFile /etc/ssl/private/apache-selfsigned.key
   <Directory /srv/www/wordpress>
       Options FollowSymLinks
       AllowOverride Limit Options FileInfo
       DirectoryIndex index.php
       Require all granted
   </Directory>
</VirtualHost>
<VirtualHost *:80>
    DocumentRoot /srv/www/wordpress
    <Directory /srv/www/wordpress>
        Options FollowSymLinks
        AllowOverride Limit Options FileInfo
        DirectoryIndex index.php
        Require all granted
    </Directory>
    <Directory /srv/www/wordpress/wp-content>
        Options FollowSymLinks
        Require all granted
    </Directory>
</VirtualHost>
EOF

sudo a2ensite wordpress
sudo a2enmod rewrite
sudo a2dissite 000-default

sudo a2enmod ssl
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/apache-selfsigned.key -out /etc/ssl/certs/apache-selfsigned.crt \
-subj "/C=US/ST=California/L=SanFrancisco/O=ExampleOrg/OU=IT/CN=example.com"
sudo systemctl restart apache2

echo "Configure WordPress to connect to the database"
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

sudo -u www-data sed -i "s/database_name_here/$WORDPRESS_DB/" "/srv/www/wordpress/wp-config.php"
sudo -u www-data sed -i "s/username_here/$WORDPRESS_USER/" "/srv/www/wordpress/wp-config.php"
sudo -u www-data sed -i "s/password_here/$WORDPRESS_PASS/" "/srv/www/wordpress/wp-config.php"

sudo -u www-data awk '
  BEGIN { repl=0 }
  /define\(\047AUTH_KEY\047,/ { repl=1 }
  repl && /define\(\047.*_KEY\047,|define\(\047.*_SALT\047,/ { next }
  { print }
  repl && !/define\(\047.*_KEY\047,|define\(\047.*_SALT\047,/ {
    system("curl -s https://api.wordpress.org/secret-key/1.1/salt/")
    repl=0
  }
' /srv/www/wordpress/wp-config.php > /srv/www/wordpress/wp-config.tmp && mv /srv/www/wordpress/wp-config.tmp /srv/www/wordpress/wp-config.php
