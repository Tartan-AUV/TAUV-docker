# builds the docker container
.PHONY: build


build:
	displayip="$(shell /bin/zsh -c "ifconfig en0 | grep inet | grep 'inet ' | cut -d' ' -f2 ")" docker-compose build
# mip=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')        

# Builds and starts the docker container in the background
.PHONY: up
up: build
	displayip="$(shell /bin/zsh -c "ifconfig en0 | grep inet | grep 'inet ' | cut -d' ' -f2 ")" docker-compose up -d && open -a XQuartz && xhost + 

# Kills the docker container
.PHONY: kill
kill:
	docker-compose kill && docker-compose rm 

# Attaches a shell to the docker container
.PHONY: attach
attach:
	docker-compose exec tauvservice /bin/bash

.PHONY: rm
rm:
	docker-compose rm

# Same as up, but also recreates the docker-compose config. (reloads the yaml, basically)
.PHONY: recreate-up
recreate-up: build
	docker-compose up -d --force-recreate
