*This project has been created as part of the 42 curriculum by kroyo-di.*

# Inception

## Description

Inception is a System Administration project that consists of building a small
web infrastructure entirely with Docker. Each service runs in its own
container, built from a custom Dockerfile, and everything is connected with
Docker Compose and a single `Makefile`.

The core stack is a classic WordPress setup:

- **NGINX** — the only entry point, serving HTTPS on port 443.
- **WordPress + php-fpm** — the content management system.
- **MariaDB** — the database.

The bonus part adds:

- **Redis** — object cache for WordPress.
- **FTP** — file access to the WordPress volume.
- **Static site** — small showcase page.
- **Adminer** — web UI to manage the database.
- **Portainer** — web UI to manage the Docker environment.

## Instructions

1. Make sure `kroyo-di.42.fr` points to `127.0.0.1` in `/etc/hosts`.
2. Create the `secrets/` folder with the required password files.
3. Create `srcs/.env` with the project configuration.
4. From the project root, run `make`.
5. Visit `https://kroyo-di.42.fr`.


## Resources

- [Docker documentation](https://docs.docker.com/)
- [Docker Compose documentation](https://docs.docker.com/compose/)
- [Inception tutorial - Dev.to](https://dev.to/alejiri/docker-nginx-wordpress-mariadb-tutorial-inception42-1eok)
- [Inception guide - Medium](https://medium.com/@ssterdev/inception-guide-42-project-part-i-7e3af15eb671)
- [WordPress installation guide](https://wordpress.org/support/article/how-to-install-wordpress/)
- [MariaDB documentation](https://mariadb.com/kb/en/documentation/)
- [NGINX documentation](https://nginx.org/en/docs/)
- [Redis documentation](https://redis.io/docs/)
- [vsftpd documentation](https://security.appspot.com/vsftpd.html)
- [Adminer](https://www.adminer.org/)
- [Portainer documentation](https://docs.portainer.io/)

### Use of AI

- Starting to configure VM with Debian
- Understanding Docker general concepts
- Helped with solving issues (MariaDB init loops, volume persistence, file
  permission conflicts between FTP and WordPress).
- Reviewed and improved scripts and Makefile.
- All changes were tested and verified on the running stack before being kept.

## Project Description

The project is split into one Dockerfile per service, all based on
`debian:bookworm`, connected through a single Docker Compose file and a custom
bridge network. The `Makefile` builds and starts everything (`make`), stops it
(`make down`), or wipes it for a clean rebuild (`make fclean`).

**Virtual Machines vs Docker** — A VM virtualizes a whole machine, which is
heavy and slow to start. Docker containers share the host kernel and only
package the app and its dependencies, making them lighter and faster — ideal
for running many isolated services on one VM.

**Secrets vs Environment Variables** — Environment variables are used for
non-sensitive config. Passwords are stored as Docker secrets, mounted
read-only inside the containers, so they never appear in `docker inspect`, the
compose file, or Git history.

**Docker Network vs Host Network** — Using the host network would remove all
isolation. Instead, containers join a custom bridge network and talk to each
other by service name. Only NGINX exposes a port to the host.

**Docker Volumes vs Bind Mounts** — Bind mounts tie storage to a fixed host
path with no Docker management. This project uses named volumes configured
with a bind driver pointing to `/home/kroyo-di/data`, combining Docker-managed
volumes with the required host storage location. Data persists across restarts
and is only removed by `make fclean`.
