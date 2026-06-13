FROM debian:bookworm

RUN apt-get update && apt-get install -y \
    wget \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q https://github.com/portainer/portainer/releases/download/2.39.3/portainer-2.39.3-linux-amd64.tar.gz -O /tmp/portainer.tar.gz \
    && tar -xzf /tmp/portainer.tar.gz -C /opt \
    && rm /tmp/portainer.tar.gz

WORKDIR /opt/portainer

EXPOSE 9000

ENTRYPOINT ["./portainer"]
