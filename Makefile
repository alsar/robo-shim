include .env

.PHONY: up down stop start restart prune sh build-phar

default: up

## help			Print commands help.
help : Makefile
	@sed -n 's/^##//p' $<

## up			Start up containers.
up:
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker compose pull
	@docker compose up -d --remove-orphans

down: stop

## stop			Stop containers.
stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker compose stop

## start			Start containers without updating.
start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker compose start

restart:
	@echo "Restarting containers for $(PROJECT_NAME)..."
	@docker compose up -d --remove-orphans --build $(filter-out $@,$(MAKECMDGOALS))

## prune			Remove containers and their volumes.
prune:
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker compose down -v

## sh			Access a container via shell.
sh:
	@echo "SSH into the $(filter-out $@,$(MAKECMDGOALS)) container..."
	@docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(filter-out $@,$(MAKECMDGOALS))' --format "{{ .ID }}") sh

## build-phar
build-phar:
	@make
	@ rm -rf var
	docker exec -it $(PROJECT_NAME)_php sh -c "git clone https://github.com/consolidation/Robo var && cd var && git checkout $(filter-out $@,$(MAKECMDGOALS)) && composer i && ./robo phar:build && cp robo.phar ../robo"
	@ rm -rf var


# https://stackoverflow.com/a/6273809/1826109
%:
	@:
