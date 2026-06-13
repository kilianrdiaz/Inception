FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    nginx \
    && rm -rf /var/lib/apt/lists/*

COPY html/index.html /var/www/html/index.html

RUN echo 'server { listen 80; root /var/www/html; index index.html; }' \
    > /etc/nginx/sites-available/default

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
