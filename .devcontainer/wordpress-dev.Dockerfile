ARG OLS_VERSION
ARG PHP_VERSION

# The base image
FROM litespeedtech/openlitespeed:${OLS_VERSION}-${PHP_VERSION}

ARG PHP_VERSION

# Install PHP dev package
RUN apt-get update && apt-get install -y ${PHP_VERSION}-dev

# Fix for lsphp symlink broken after installing ${PHP_VERSION}-dev
RUN ln -fs /usr/local/lsws/${PHP_VERSION}/bin/php /usr/bin/php

# Install xdebug and create configuration file
RUN yes | pecl install xdebug \
    && echo "zend_extension=$(find /usr/local/lsws/${PHP_VERSION} -name xdebug.so)" > "$(find /usr/local/lsws/${PHP_VERSION}/etc/php -depth -name mods-available)/xdebug.ini" \
    && echo "xdebug.mode=debug,develop" >> "$(find /usr/local/lsws/${PHP_VERSION}/etc/php -depth -name mods-available)/xdebug.ini" \
    && echo "xdebug.start_with_request=yes" >> "$(find /usr/local/lsws/${PHP_VERSION}/etc/php -depth -name mods-available)/xdebug.ini" \
    && echo "xdebug.discover_client_host=1" >> "$(find /usr/local/lsws/${PHP_VERSION}/etc/php -depth -name mods-available)/xdebug.ini"

# Install Node.js LTS
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - && \
    apt-get install -y nodejs

# Cache NPM packages
RUN mkdir /tmp/packages
COPY ./workspace-vscode/package*.json /tmp/packages
RUN npm install --yes --prefix /tmp/packages

# Create 'vscode' user; add user to 'lsadm' group
RUN useradd -ms /bin/bash vscode && usermod -aG lsadm vscode

# Copy wordpress installer script into the container
COPY ./wordpress-install.sh /wordpress-install.sh
RUN chmod +x /wordpress-install.sh

# Configure container entrypoint
COPY ./entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]