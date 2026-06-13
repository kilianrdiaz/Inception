#!/bin/bash
set -e

echo "Starting Adminer..."

# Start PHP built-in server
exec php -S 0.0.0.0:8080 -t /var/www/html
