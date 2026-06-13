FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    php8.2-fpm \
    php8.2-mysql \
    wget \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /var/www/html && \
    wget -q https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php \
    -O /var/www/html/adminer.php

COPY tools/start_adminer.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/start_adminer.sh

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/start_adminer.sh"]
