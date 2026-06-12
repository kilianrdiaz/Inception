# Developer Documentation

How to set up, build, run, and maintain the Inception project.

## 1. Project structure

```
.
├── Makefile
├── secrets/
│   ├── db_root_password.txt
│   ├── db_password.txt
│   └── ftp_password.txt
└── srcs/
    ├── .env
    ├── docker-compose.yml
    └── requirements/
        ├── mariadb/
        ├── wordpress/
        ├── nginx/
        ├── redis/
        ├── ftp/
        ├── adminer/
        ├── static/
        └── portainer/
```

Each service folder contains its own `Dockerfile`, plus configuration files
and entrypoint scripts.

## 2. Prerequisites

- A Linux VM with Docker and Docker Compose.
- `sudo` access, needed to manage data directories under `/home/kroyo-di/data`.
- `/etc/hosts`:
  ```
  127.0.0.1   kroyo-di.42.fr
  ```

## 3. Configuration files

**`srcs/.env`** — general configuration used by Docker Compose:

```
DOMAIN_NAME=kroyo-di.42.fr
MYSQL_DATABASE=wordpress_db
MYSQL_USER=wp_user
WORDPRESS_DB_NAME=wordpress_db
WORDPRESS_DB_USER=wp_user
WORDPRESS_DB_HOST=mariadb
WORDPRESS_TABLE_PREFIX=wp_
FTP_USER=ftpuser
DATA_PATH=/home/kroyo-di/data
```

**`secrets/`** — password files, excluded from Git, mounted read-only inside
the containers:

```
secrets/db_root_password.txt
secrets/db_password.txt
secrets/ftp_password.txt
```

Entrypoint scripts read these through dedicated environment variables.

## 4. Build and launch

| Command | Effect |
|---|---|
| `make` / `make all` | Create data directories, build all images, start everything |
| `make build` | Build images only |
| `make up` | Start containers from existing images |
| `make down` | Stop containers, data is preserved |
| `make clean` | Stop and remove unused images and cache |
| `make fclean` | Remove volumes and wipe all project data |
| `make re` | Full rebuild from scratch |

**First run**: `make` builds all images and starts every container. MariaDB
initializes its database and WordPress downloads and configures itself. Then
complete the WordPress install wizard at `https://kroyo-di.42.fr`.

**Later runs**: `make down` followed by `make up` keeps all existing data and
configuration.

## 5. Managing containers, volumes, and networks

```bash
docker ps                          # running containers
docker logs <name>                 # logs
docker exec -it <name> bash        # shell inside a container
docker restart <name>              # restart one service

docker volume ls                   # mariadb_data, wordpress_data
docker volume inspect mariadb_data # shows path on host

docker network ls
docker network inspect srcs_inception-network
```

NGINX, the static site, Adminer, Redis, FTP, and Portainer publish ports
to the host. MariaDB and WordPress are only reachable inside the Docker
network.

## 6. Data storage and persistence

| Data | Host path | Volume |
|---|---|---|
| MariaDB database | `/home/kroyo-di/data/mariadb` | `mariadb_data` |
| WordPress files | `/home/kroyo-di/data/wordpress` | `wordpress_data` |

Both are Docker named volumes using a bind driver. Data persists across
`make down`/`make up` and is only removed by `make fclean` or `make re`.

