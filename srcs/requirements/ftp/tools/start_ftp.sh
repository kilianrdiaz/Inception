#!/bin/bash
set -e

# Read password from secret if exists
if [ -f "${FTP_PASSWORD_FILE}" ]; then
    FTP_PASSWORD=$(cat "${FTP_PASSWORD_FILE}")
fi

if [ -z "${FTP_USER}" ] || [ -z "${FTP_PASSWORD}" ]; then
    echo "ERROR: FTP_USER or FTP_PASSWORD is empty"; exit 1
fi

# Create FTP user if not exists
if ! id "${FTP_USER}" &>/dev/null; then
    useradd -m -d /var/www/html -s /bin/bash "${FTP_USER}"
    echo "${FTP_USER}:${FTP_PASSWORD}" | chpasswd
    chown "${FTP_USER}:${FTP_USER}" /var/www/html
fi

# Configure vsftpd
cat > /etc/vsftpd.conf << CONF
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=YES
local_umask=022
dirmessage_enable=YES
use_localtime=YES
xferlog_enable=YES
connect_from_port_20=YES
chroot_local_user=YES
allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
pam_service_name=vsftpd
pasv_enable=YES
pasv_min_port=21100
pasv_max_port=21110
pasv_address=127.0.0.1
CONF

mkdir -p /var/run/vsftpd/empty

echo "Starting FTP server..."
exec vsftpd /etc/vsftpd.conf
