# Evaluation Preparation — Inception

This document maps every point of the official evaluation sheet to the current
state of the project, with the status and the action required before the
defense.

Legend: ✅ OK · ⚠️ To verify / prepare · ❌ CRITICAL — would end the evaluation

---

## 0. Preliminary tests

| Check | Status | Notes |
|---|---|---|
| Credentials only in `.env` / `secrets/`, nothing else in the repo | ✅ | `.env` and `secrets/` are gitignored, passwords only there |
| Full docker cleanup + `make` works | ⚠️ | Test with: `docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -q); docker network rm $(docker network ls -q) 2>/dev/null; make` |

---

## 1. General instructions

| Check | Status | Notes |
|---|---|---|
| `srcs/` at the root of the repo | ✅ | |
| `Makefile` at the root of the repo | ✅ | |
| No `network: host` or `links:` in `docker-compose.yml` | ✅ | We use `inception-network` |
| `networks:` section present in `docker-compose.yml` | ✅ | |
| No `--link` anywhere | ✅ | |
| No `tail -f`, `sleep infinity`, background processes in ENTRYPOINT | ✅ | All entrypoints end with `exec <main process>` |
| Makefile runs without crash | ⚠️ | Must re-test after fixing the issues below |

---

## 2. Project overview (oral explanation)

You will be asked to explain, in simple terms:

### How Docker and Docker Compose work
Docker builds images from Dockerfiles and runs them as isolated containers
that share the host kernel. Docker Compose reads a single YAML file
(`docker-compose.yml`) describing all the services, networks, volumes, and
how they relate, and starts/stops the whole stack with one command.

### Difference: Docker image with vs without Docker Compose
A Docker image run directly with `docker run` is isolated — you must manually
create networks, link containers, and manage volumes for each one. With
Docker Compose, all containers are defined together, automatically joined to
the same network (so they can reach each other by service name), and managed
as a single unit (`up`/`down`/`build`).

### Benefit of Docker compared to VMs
A VM virtualizes an entire machine (kernel, OS, drivers) — heavy, slow to
start. A container shares the host kernel and only packages the
application and its dependencies — lightweight, starts in seconds, and lets
you run many isolated services on a single VM, which is exactly what this
project does.

### Pertinence of the directory structure
- `secrets/` — sensitive files, isolated and gitignored.
- `srcs/.env` — non-sensitive configuration shared by all services.
- `srcs/docker-compose.yml` — single orchestration file.
- `srcs/requirements/<service>/` — one folder per service, each with its own
  `Dockerfile` and `conf/`/`tools/` subfolders, keeping every service
  self-contained and easy to maintain independently.

---

## 3. Simple setup

| Check | Status | Notes |
|---|---|---|
| NGINX accessible only on 443 | ✅ | `docker-compose.yml` exposes only `443:443` for nginx |
| SSL/TLS certificate used | ✅ | Self-signed cert generated at container startup |
| `https://kroyo-di.42.fr` shows the configured WordPress site (no install page) | ⚠️ | Must verify after fixing the admin username issue (see below) |
| `http://kroyo-di.42.fr` should not show the WordPress site | ✅ | Port 80 is served by the **static bonus site**, not WordPress — be ready to explain this to the evaluator |

---

## 4. Docker Basics

| Check | Status | Notes |
|---|---|---|
| One Dockerfile per service, none empty | ✅ | mariadb, wordpress, nginx, redis, ftp, adminer, static, portainer |
| Dockerfiles written from scratch, no ready-made images | ❌ **CRITICAL** | `portainer/Dockerfile` uses `FROM portainer/portainer-ce:latest` — this is a ready-made image from Docker Hub, **not allowed**. See action below. |
| Every Dockerfile starts with `FROM debian:XXXXX` (penultimate stable) | ❌ **CRITICAL** | `nginx/Dockerfile` uses `FROM debian:bullseye` (Debian 11). The current penultimate stable is `bookworm` (Debian 12, since `trixie`/13 became stable). All other services already use `bookworm`. |
| Image names match service names | ✅ | `mariadb:inception`, `wordpress:inception`, etc. |
| `make` builds everything via Docker Compose, no crash | ⚠️ | Re-test once the two points above are fixed |

### Action required — Portainer (free choice service)
Replace the Portainer Dockerfile (built `FROM portainer/portainer-ce:latest`)
with a custom-built service starting `FROM debian:bookworm`. Options:
- Build Portainer from its source release binary inside a `debian:bookworm`
  Dockerfile (download the binary, don't use the pre-built image).
- Or replace the free-choice service entirely with something simpler to build
  from scratch (e.g. a small monitoring dashboard using `ctop`, `netdata`, or
  a custom script).

### Action required — NGINX base image
Change `srcs/requirements/nginx/Dockerfile`:
```dockerfile
FROM debian:bullseye
```
to:
```dockerfile
FROM debian:bookworm
```
Rebuild and re-test the full stack afterwards (`make fclean && make`).

---

## 5. Docker Network

| Check | Status | Notes |
|---|---|---|
| `docker-compose.yml` defines a network | ✅ | `inception-network` (bridge) |
| `docker network ls` shows it | ✅ | |
| Can explain Docker network simply | ⚠️ | Prepare a short explanation (see below) |

### Talking point
"All containers are connected to a custom bridge network created by Docker
Compose. Inside this network, each container can reach the others by their
service name — for example, WordPress connects to `mariadb` and NGINX
forwards PHP requests to `wordpress:9000`. Only NGINX exposes a port to the
host, so it's the only way to reach the infrastructure from outside."

---

## 6. NGINX with SSL/TLS

| Check | Status | Notes |
|---|---|---|
| Dockerfile exists | ✅ | |
| `docker compose ps` shows the container | ✅ | |
| Port 80 does not serve WordPress | ⚠️ | Port 80 is used by the static bonus site — explain this is a separate bonus container, NGINX itself only listens on 443 |
| `https://kroyo-di.42.fr` shows configured WordPress | ⚠️ | Verify after fixing admin username |
| TLS 1.2/1.3 demonstrated | ✅ | `ssl_protocols TLSv1.2 TLSv1.3;` in `nginx.conf`. Can demonstrate with: `openssl s_client -connect kroyo-di.42.fr:443 -tls1_2` and `-tls1_3` |

---

## 7. WordPress with php-fpm and its volume

| Check | Status | Notes |
|---|---|---|
| Dockerfile exists, no NGINX inside | ✅ | |
| `docker compose ps` shows the container | ✅ | |
| Volume path contains `/home/kroyo-di/data/` | ✅ | `docker volume inspect wordpress_data` → device `/home/kroyo-di/data/wordpress` |
| Can add a comment using an available WordPress user | ❌ **CRITICAL** | Only one WordPress user (the admin) currently exists. Need a second user. |
| Admin username doesn't contain "admin"/"Admin" | ❌ **CRITICAL** | Must verify the username chosen during install. If it contains "admin", create a new administrator account with a valid name and demote/remove the old one. |
| Edit a page from dashboard, see the change live | ✅ | Standard WordPress functionality, should work once installed correctly |

### Action required — WordPress users
The subject requires **two users in the WordPress database, one of them being
the administrator**, and the admin username must not contain "admin" or
"Admin" in any form.

1. Go to `wp-admin` → Users → Add New.
2. Create a second user (e.g. role: Subscriber or Editor) — this satisfies
   "two users" and gives you an account to test commenting with.
3. Check the existing administrator's username:
   - If it's something like `admin`, create a **new** administrator account
     with a different username (e.g. `kroyo_owner`), log in with it, then
     either delete the old `admin` account (reassigning its content to the
     new one) or change its role away from Administrator.

---

## 8. MariaDB and its volume

| Check | Status | Notes |
|---|---|---|
| Dockerfile exists, no NGINX inside | ✅ | |
| `docker compose ps` shows the container | ✅ | |
| Volume path contains `/home/kroyo-di/data/` | ✅ | `docker volume inspect mariadb_data` → device `/home/kroyo-di/data/mariadb` |
| Can explain how to log into the database | ⚠️ | Prepare the command below |
| Database is not empty | ✅ | Contains `wordpress_db` with WordPress tables |

### Talking point / command
```bash
docker exec -it mariadb mysql -u wp_user -p wordpress_db
```
(password from `secrets/db_password.txt`), or as root:
```bash
docker exec -it mariadb mysql -u root -p
```
(password from `secrets/db_root_password.txt`).

---

## 9. Persistence

| Check | Status | Notes |
|---|---|---|
| Reboot the VM, run `make`/`docker compose up`, everything still works | ⚠️ | We tested `make down` + `make up`, but **not a full VM reboot**. Do this before the defense. |
| WordPress and MariaDB configuration still present | ⚠️ | Same as above |
| Previous changes to the site are still visible | ⚠️ | Make a visible change (e.g. edit a page) before testing the reboot |

### Action required
1. Make a visible change to the WordPress site (edit a page, add a post).
2. Reboot the VM: `sudo reboot`.
3. After reboot, run `make` (or `make up` if images already exist) from the
   project root.
4. Confirm `https://kroyo-di.42.fr` still shows the site with your change,
   and `docker exec -it mariadb mysql ...` still shows the database content.

---

## 10. Bonus

Only evaluated if the mandatory part is **perfect**. Current bonus services:

| Bonus | Status | Notes |
|---|---|---|
| Redis cache | ✅ | Connected and reachable in WordPress |
| FTP server pointing to WordPress volume | ✅ | Tested upload/download |
| Static website (non-PHP) | ✅ | HTML/CSS showcase page on port 80 |
| Adminer | ✅ | Working, can browse `wordpress_db` |
| Free choice service (Portainer) | ❌ **CRITICAL** | Currently built from a ready-made image — must be rebuilt from `debian:bookworm` or replaced (see section 4) |

For the free-choice service, be ready to explain **what it does and why it's
useful** — e.g. "it provides a web dashboard to monitor and manage all the
project's containers, volumes, and networks without using the CLI."

---

## Priority action list before the defense

1. **Fix `nginx/Dockerfile`** → `FROM debian:bookworm` (rebuild + retest).
2. **Fix or replace Portainer Dockerfile** → must be built from `debian:bookworm`
   with no ready-made image.
3. **Check / fix the WordPress administrator username** (no "admin"/"Admin").
4. **Create a second WordPress user** and test adding a comment.
5. **Full `make fclean && make`** to confirm everything still builds and runs
   cleanly after the above changes.
6. **Reboot the VM** and confirm persistence of WordPress + MariaDB data.
7. Prepare the oral explanations in sections 2, 5, and 8.
