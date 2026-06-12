*This project has been created as part of the 42 curriculum by kroyo-di.*

# Inception

## Description

Inception is a System Administration project that consists of building a small
web infrastructure entirely with Docker. Each service runs in its own container,
built from a custom Dockerfile, and everything is connected with Docker
Compose and a single `Makefile`.

The core stack (mandatory part) is a classic WordPress setup:

- **NGINX** — the only entry point, serving HTTPS (TLSv1.2/1.3) on port 443.
- **WordPress + php-fpm** — the CMS.
- **MariaDB** — the database.

The bonus part adds:

- **Redis** — object cache for WordPress.
- **FTP** — file access to the WordPress volume.
- **Static site** — small showcase page (HTML/CSS).
- **Adminer** — web UI to manage the database.
- **Portainer** — web UI to manage the Docker environment.

## Instructions

1. Make sure `kroyo-di.42.fr` points to `127.0.0.1` in `/etc/hosts`.
2. Create the `secrets/` folder with the required password files.
3. Create `srcs/.env` with the project configuration.
4. From the project root, run `make`
5. Visit `https://kroyo-di.42.fr`.


## Resources

- [Docker documentation](https://docs.docker.com/)
- [Dev.to article](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
- [Medium article](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [WordPress installation guide](https://wordpress.org/support/article/how-to-install-wordpress/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [Redis documentation](https://redis.io/docs/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Adminer](https://www.adminer.org/)
- [Portainer documentation](https://docs.portainer.io/)

### Use of AI

AI (Claude) was used as a learning and debugging aid throughout the project:
explaining Docker/Linux concepts before applying them, debugging recurring
issues (MariaDB init loops, volume persistence, file permission conflicts
between FTP and WordPress), reviewing scripts and the Makefile, and drafting
this documentation. All changes were tested and verified on the running stack
before being kept.

## Project Description

The project is split into one Dockerfile per service, all based on
`debian:bookworm`, connected through a single Docker Compose file and a custom
bridge network (`inception-network`). The `Makefile` builds and starts
everything (`make`), stops it (`make down`), or wipes it for a clean rebuild
(`make fclean`).

**Virtual Machines vs Docker** — A VM virtualizes a whole machine (own kernel,
OS, drivers), which is heavy and slow to start. Docker containers share the
host kernel and only package the app and its dependencies, making them much
lighter and faster — ideal for running many isolated services on one VM, as
this project does.

**Secrets vs Environment Variables** — Environment variables (in `.env`) are
fine for non-sensitive config (domain, DB names, usernames). Passwords are
stored as Docker secrets (files in `secrets/`, mounted read-only at
`/run/secrets/`), so they never appear in `docker inspect`, the compose file,
or Git history.

**Docker Network vs Host Network** — `network: host` would remove all network
isolation. Instead, all containers join a custom bridge network and talk to
each other by service name. Only NGINX exposes a port to the host, acting as
the single entry point.

**Docker Volumes vs Bind Mounts** — Bind mounts tie storage to a fixed host
path with no Docker management. This project uses named volumes
(`mariadb_data`, `wordpress_data`) configured with a `local` bind driver
pointing to `/home/kroyo-di/data`, combining Docker-managed volumes with the
required host storage location. Data persists across `make down`/`make up`,
and is only removed by `make fclean`.
