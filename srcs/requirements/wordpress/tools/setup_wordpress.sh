#!/bin/bash
set -e

WP_PATH="/var/www/html"

if [ -f "${WORDPRESS_DB_PASSWORD_FILE}" ]; then
    WORDPRESS_DB_PASSWORD=$(cat "${WORDPRESS_DB_PASSWORD_FILE}")
    export WORDPRESS_DB_PASSWORD
fi
if [ -f "${WP_ADMIN_PASSWORD_FILE}" ]; then
    WP_ADMIN_PASSWORD=$(cat "${WP_ADMIN_PASSWORD_FILE}")
fi
if [ -f "${WP_USER_PASSWORD_FILE}" ]; then
    WP_USER_PASSWORD=$(cat "${WP_USER_PASSWORD_FILE}")
fi

if [ -z "${WORDPRESS_DB_NAME}" ]; then echo "ERROR: WORDPRESS_DB_NAME is empty"; exit 1; fi
if [ -z "${WORDPRESS_DB_USER}" ]; then echo "ERROR: WORDPRESS_DB_USER is empty"; exit 1; fi
if [ -z "${WORDPRESS_DB_PASSWORD}" ]; then echo "ERROR: WORDPRESS_DB_PASSWORD is empty"; exit 1; fi
if [ -z "${WORDPRESS_DB_HOST}" ]; then echo "ERROR: WORDPRESS_DB_HOST is empty"; exit 1; fi

echo "Setting up WordPress..."

if [ ! -f "$WP_PATH/wp-config.php" ]; then
    echo "Downloading WordPress..."
    wget -q --timeout=30 https://wordpress.org/latest.tar.gz -O /tmp/wordpress.tar.gz || {
        echo "ERROR: Failed to download WordPress"; exit 1
    }
    tar -xzf /tmp/wordpress.tar.gz -C /tmp
    rm /tmp/wordpress.tar.gz
    cp -rn /tmp/wordpress/* "$WP_PATH" || true
    rm -rf /tmp/wordpress

    echo "Fetching WordPress salts..."
    WP_SALTS=$(wget -qO- --timeout=30 https://api.wordpress.org/secret-key/1.1/salt/) || {
        echo "WARNING: Could not fetch salts, using placeholder"
        WP_SALTS="define('AUTH_KEY', '$(openssl rand -base64 48)');"
    }

    cat > "$WP_PATH/wp-config.php" << WPEOF
<?php
define('DB_NAME', '${WORDPRESS_DB_NAME}');
define('DB_USER', '${WORDPRESS_DB_USER}');
define('DB_PASSWORD', '${WORDPRESS_DB_PASSWORD}');
define('DB_HOST', '${WORDPRESS_DB_HOST}');
define('DB_CHARSET', 'utf8');
define('DB_COLLATE', '');
\$table_prefix = '${WORDPRESS_TABLE_PREFIX:-wp_}';
${WP_SALTS}
define('WP_REDIS_HOST', 'redis');
define('WP_REDIS_PORT', 6379);
define('WP_CACHE', true);
define('WP_DEBUG', false);
if ( !defined('ABSPATH') )
    define('ABSPATH', __DIR__ . '/');
require_once ABSPATH . 'wp-settings.php';
WPEOF

    find "$WP_PATH" -type d -exec chmod 750 {} \;
    find "$WP_PATH" -type f -exec chmod 640 {} \;
echo "Waiting for MariaDB to be ready..."
    until mysqladmin ping -h "${WORDPRESS_DB_HOST}" -u "${WORDPRESS_DB_USER}" -p"${WORDPRESS_DB_PASSWORD}" --silent 2>/dev/null; do
        sleep 2
    done
    echo "MariaDB is ready!"        sleep 2
    echo "Installing WordPress..."
    wp core install \
        --allow-root \
        --path="$WP_PATH" \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    echo "Creating second user..."
    wp user create \
        --allow-root \
        --path="$WP_PATH" \
        "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=subscriber

    echo "WordPress setup complete."
else
    echo "WordPress already initialized, skipping setup."
fi

echo "Starting PHP-FPM..."
chown -R www-data:www-data "$WP_PATH"
chmod 755 "$WP_PATH"
exec php-fpm8.2 -F
