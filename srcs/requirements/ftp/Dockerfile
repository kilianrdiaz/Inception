FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    vsftpd \
    && rm -rf /var/lib/apt/lists/*

COPY tools/start_ftp.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_ftp.sh

EXPOSE 21 20 21100-21110

ENTRYPOINT ["/usr/local/bin/start_ftp.sh"]
