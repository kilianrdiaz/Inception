# User Documentation

This guide explains how to use the Inception stack: available services, how to
start and stop it, how to access the site and admin tools, where credentials
are kept, and how to check everything is running.

## 1. Services

| Service | What it's for | Address |
|---|---|---|
| WordPress site | The main website | `https://kroyo-di.42.fr` |
| WordPress admin | Manage content and users | `https://kroyo-di.42.fr/wp-admin` |
| Adminer | Manage the database | `http://kroyo-di.42.fr:8080/adminer.php` |
| Static site | Project showcase page | `http://kroyo-di.42.fr` |
| Portainer | Manage the Docker containers | `http://kroyo-di.42.fr:9000` |
| Redis | Cache for WordPress | internal, port `6379` |
| FTP | File access to WordPress files | `kroyo-di.42.fr`, port `21` |

All web traffic goes through NGINX on port 443.

## 2. Start and stop

Run from the project root:

- **Start everything**: `make`
- **Stop**: `make down` (data is kept)
- **Start again**: `make up`
- **Full reset**: `make fclean` (wipes all data, WordPress needs reinstalling)
- **Full rebuild**: `make re`

## 3. Accessing the site and admin panels

- **Website**: `https://kroyo-di.42.fr`. The browser will warn about the
  certificate — accept it to continue.
- **WordPress admin**: `https://kroyo-di.42.fr/wp-admin`.
- **Adminer**: `http://kroyo-di.42.fr:8080/adminer.php`. Connect using server
  `mariadb` and the WordPress database credentials.
- **Portainer**: `http://kroyo-di.42.fr:9000`. Create an admin account on
  first visit.
- **FTP**: connect to `kroyo-di.42.fr` on port 21 with any FTP client.

## 4. Credentials

- General configuration: `srcs/.env`
- Passwords: `secrets/db_root_password.txt`, `secrets/db_password.txt`,
  `secrets/ftp_password.txt`
- WordPress admin account: created during the install wizard. Write it down,
  it isn't stored anywhere else.

`.env` and `secrets/` are excluded from Git.

## 5. Checking everything works
 
- `docker ps` — all containers should show `Up`.
- `docker logs <name>` — check for errors.
- Open the website and Adminer to confirm the database and content load.
- In WordPress admin, go to Settings → Redis and confirm it shows Connected.
- Connect via FTP to `kroyo-di.42.fr` and confirm you can browse the
  WordPress files.
- Open `http://kroyo-di.42.fr` and confirm the static showcase page loads.
- Open Portainer and confirm all containers show as `running`.
