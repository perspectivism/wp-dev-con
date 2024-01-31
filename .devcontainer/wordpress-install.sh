#!/bin/bash
PLUGINS='litespeed-cache'
WP_DIR="/var/www/vhosts/${DOMAIN}/html"

cd "${WP_DIR}"

# Check if WordPress is already installed
if [ -f 'wp-config.php' ]; then
    exit 0
fi

# Configure htaccess file
cat << EOM > .htaccess
# BEGIN WordPress
<IfModule mod_rewrite.c>
RewriteEngine On
RewriteBase /
RewriteRule ^index\.php$ - [L]
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule . /index.php [L]
</IfModule>
# END WordPress
EOM

# Install and configure WordPress
wp core download --allow-root
wp core config --dbhost='mysql' --dbname="${MYSQL_DATABASE}" --dbuser="${MYSQL_USER}" --dbpass="${MYSQL_PASSWORD}" --allow-root
wp core install --url=localhost --title="${WP_TITLE}" --admin_name="${WP_ADMIN_NAME}" --admin_password="${WP_ADMIN_PASSWORD}" --admin_email="${WP_ADMIN_EMAIL}" --allow-root
wp plugin delete akismet hello --allow-root
wp plugin install "$PLUGINS" --allow-root
wp plugin activate custom-plugin --allow-root
wp theme delete twentytwentythree twentytwentytwo --allow-root
wp theme activate custom-theme --allow-root

# Restrict access to wp-config.php
chmod 600 wp-config.php