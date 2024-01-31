#!/bin/bash

copy_conf_files() {
    local SOURCE_DIR=$1
    local DEST_DIR=$2

    if [ -z "$(ls -A -- "${DEST_DIR}")" ]; then
        cp -R "${SOURCE_DIR}/.conf/"* "${DEST_DIR}"
    fi
}

move_npm_cache_to_target() {
    local PKG_DIR='/tmp/packages'
    if [ -d "${PKG_DIR}" ]; then
        mv "${PKG_DIR}/node_modules" /var/www/vhosts
        rm -rf "${PKG_DIR}"
    fi
}

set_ols_webadmin_password() {
    local LSADPATH='/usr/local/lsws/admin'
    echo "admin:$(${LSADPATH}/fcgi-bin/admin_php -q ${LSADPATH}/misc/htpasswd.php ${OLS_WEB_ADMIN_PASSWORD})" > "${LSADPATH}/conf/htpasswd"
}

# Copy configuration files to respective directories
copy_conf_files "/usr/local/lsws" "/usr/local/lsws/conf"
copy_conf_files "/usr/local/lsws/admin" "/usr/local/lsws/admin/conf"

# Set OLS web admin password
set_ols_webadmin_password

# Move NPM package cache to target
move_npm_cache_to_target

# Install WordPress
/wordpress-install.sh

# Set permissions
chmod -R ug+rw /usr/local/lsws/admin/conf
chmod 775 /usr/local/lsws/admin/conf

# Set ownership
chown -R 999:999 /usr/local/lsws/conf
chown -R vscode:lsadm /usr/local/lsws/admin/conf
chown -R vscode:lsadm /var/www/vhosts

# Start 'parcel watch' in the background with user 'vscode'
su - vscode -c 'cd /var/www/vhosts && npm run watch &'

# Start LiteSpeed Web Server
/usr/local/lsws/bin/lswsctrl start

# Wait for LiteSpeed to be running
while true; do
    if ! /usr/local/lsws/bin/lswsctrl status | grep -q 'litespeed is running with PID *'; then
        break
    fi
    sleep 60
done