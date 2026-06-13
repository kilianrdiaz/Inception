# Variables
COMPOSE_FILE = srcs/docker-compose.yml
DATA_DIR = /home/$(USER)/data

.PHONY: all build up down clean fclean re

all: build up

# Create data directories
$(DATA_DIR)/mariadb:
	mkdir -p $(DATA_DIR)/mariadb

$(DATA_DIR)/wordpress:
	mkdir -p $(DATA_DIR)/wordpress

# Build images
build: $(DATA_DIR)/mariadb $(DATA_DIR)/wordpress
	docker compose -f $(COMPOSE_FILE) build

# Start services
up:
	docker compose -f $(COMPOSE_FILE) up -d

# Stop services
down:
	docker compose -f $(COMPOSE_FILE) down

# Clean containers and images
clean:
	docker compose -f $(COMPOSE_FILE) down
	docker system prune -af

# Full clean including volumes
fclean: clean
	docker volume rm mariadb_data wordpress_data srcs_mariadb_data srcs_wordpress_data 2>/dev/null || true
	sudo chown -R $(USER):$(USER) $(DATA_DIR) 2>/dev/null || true
	sudo rm -rf $(DATA_DIR)/mariadb
	sudo rm -rf $(DATA_DIR)/wordpress
	sudo mkdir -p $(DATA_DIR)/mariadb
	sudo mkdir -p $(DATA_DIR)/wordpress

# Rebuild everything
re: fclean all
