#!/bin/bash
set -e

if [ -f "${MYSQL_ROOT_PASSWORD_FILE}" ]; then
    MYSQL_ROOT_PASSWORD=$(cat "${MYSQL_ROOT_PASSWORD_FILE}")
fi
if [ -f "${MYSQL_PASSWORD_FILE}" ]; then
    MYSQL_PASSWORD=$(cat "${MYSQL_PASSWORD_FILE}")
fi

if [ -z "${MYSQL_ROOT_PASSWORD}" ]; then
    echo "ERROR: MYSQL_ROOT_PASSWORD is empty"; exit 1
fi
if [ -z "${MYSQL_DATABASE}" ]; then
    echo "ERROR: MYSQL_DATABASE is empty"; exit 1
fi
if [ -z "${MYSQL_USER}" ]; then
    echo "ERROR: MYSQL_USER is empty"; exit 1
fi
if [ -z "${MYSQL_PASSWORD}" ]; then
    echo "ERROR: MYSQL_PASSWORD is empty"; exit 1
fi

echo "Starting MariaDB initialization..."

if [ ! -d "/var/lib/mysql/${MYSQL_DATABASE}" ]; then
    echo "First run - initializing data directory..."
    mysql_install_db --user=mysql --datadir=/var/lib/mysql > /dev/null

    echo "Starting temporary MariaDB server for setup..."
    mysqld --skip-networking --socket=/run/mysqld/mysqld.sock --user=mysql &
    pid="$!"

    echo "Waiting for MariaDB to be ready..."
    until mysqladmin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
        sleep 1
    done
    echo "MariaDB is ready!"

    echo "Running setup SQL..."
    mysql --socket=/run/mysqld/mysqld.sock -u root << EOSQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOSQL

    echo "Shutting down temporary MariaDB..."
    mysqladmin --socket=/run/mysqld/mysqld.sock -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown
    wait "$pid" || true
    echo "Initialization complete."
else
    echo "Data already exists, skipping initialization..."
fi

echo "Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock
