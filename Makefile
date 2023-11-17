WORKDIR_HOST ?= $(shell pwd)
WORKDIR_CONTAINER ?= /workdir
DOCKER_SCRIPT_PATH ?= ./docker
DOCKER_IMAGE ?= docker/ubuntu_ppt
DOCKER_NETWORK ?= pptnet
DOCKER_SUBNET ?= 172.23.0.0/16
DOCKER_IP ?= 172.23.0.80
DOCKER_UID ?= $(shell id -u)
DOCKER_GID ?= $(shell id -g)
CONTAINER_PORT ?= 8008
HPORT ?= 8008
CONTAINER_PORT_2 ?= 8000
HPORT_2 ?= 8000
ENTER_VENV ?= true
PYTHON_VENV_PATH ?= ./.venv
REVEAL_VERSION ?= 4.6.1

.DEFAULT_GOAL := help

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
  match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
  if match:
    target, help = match.groups()
    print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

.PHONY: help
help:
	@echo "Help:"
	@echo "Check out the variables at the beginning of the Makefile"
	@echo
	@echo "Targets:"
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

.PHONY: all 
all: compose network reveal run ## Compose image, setup docker network and run container

.PHONY: run 
run: ## Run built docker container: $ HPORT=8889 CONTAINER_PORT=8889 make run
	( \
  	docker run \
  		-p 127.0.0.1:$(HPORT):$(CONTAINER_PORT) \
  		-p 127.0.0.1:$(HPORT_2):$(CONTAINER_PORT_2) \
			-e CONTAINER_PORT=$(CONTAINER_PORT) \
			-e ENTER_VENV=$(ENTER_VENV) \
  		--mount type=bind,source=$(WORKDIR_HOST),target=$(WORKDIR_CONTAINER) \
  		--net $(DOCKER_NETWORK) \
  		--hostname $(DOCKER_IMAGE) \
  		--ip $(DOCKER_IP) \
  		-it $(DOCKER_IMAGE):latest \
	)

.PHONY: run_debug
run_debug: ## Start container into shell instead of default command (specify user): $ HPORT=8889 CONTAINER_PORT=8889 make run_debug DOCKER_UID=0 
	( \
  	docker run \
  		-p 127.0.0.1:$(HPORT):$(CONTAINER_PORT) \
			-e CONTAINER_PORT=$(CONTAINER_PORT) \
			-e ENTER_VENV=$(ENTER_VENV) \
  		--mount type=bind,source=$(WORKDIR_HOST),target=$(WORKDIR_CONTAINER) \
  		--net $(DOCKER_NETWORK) \
  		--hostname $(DOCKER_IMAGE) \
  		--ip $(DOCKER_IP) \
			--user $(DOCKER_UID) \
  		-it --entrypoint /bin/bash $(DOCKER_IMAGE):latest \
	)
#-it $(DOCKER_IMAGE):latest /bin/bash \

.PHONY: exec
exec: ## Run shell in running container: $ make exec DOCKER_UID=0
	( \
		export CONTAINER_ID=$$(docker ps | grep $(DOCKER_IMAGE) | head -n 1 | cut -d" " -f1); \
		docker exec \
			--user $(DOCKER_UID) \
			-it $${CONTAINER_ID} /bin/bash  \
	)

.PHONY: update-py
update-py: ## Run shell in running container and update python environment
	( \
		export CONTAINER_ID=$$(docker ps | grep $(DOCKER_IMAGE) | head -n 1 | cut -d" " -f1); \
		echo "CONTAINER_ID accsessed: $${CONTAINER_ID}"; \
		docker exec \
			--user $(DOCKER_UID) \
			-it $${CONTAINER_ID} /bin/bash -c '. ${PYTHON_VENV_PATH}/bin/activate && python3 -m pip install --upgrade pip && python3 -m pip install --upgrade -r requirements.txt' \
	)

.PHONY: compose
compose: ## Compose image from Dockerfile: $ make compose DOCKER_IMAGE=ubuntu_math
	( \
		export DOCKER_UID=$(DOCKER_UID); \
		export DOCKER_GID=$(DOCKER_GID); \
		export CONTAINER_PORT=$(CONTAINER_PORT); \
	  bash $(DOCKER_SCRIPT_PATH)/docker_compose.sh "$(DOCKER_IMAGE)"; \
	)

.PHONY: network
network: ## Create docker network
	( \
		bash $(DOCKER_SCRIPT_PATH)/docker_network.sh $(DOCKER_NETWORK); \
	)

.PHONY: reveal
reveal: ## Clone reveal.js git repository into local folder
	( \
		git clone https://github.com/hakimel/reveal.js.git; \
		cd reveal.js && git checkout $(REVEAL_VERSION) \
	) 

.PHONY: html_docker
html_docker: ## Export all jupyter files in root dir reveal.js slides.html (runs in docker)
	( \
		export CONTAINER_ID=$$(docker ps | grep $(DOCKER_IMAGE) | cut -d" " -f1); \
		docker exec \
			--user $(DOCKER_UID) \
			-it $${CONTAINER_ID} /bin/bash -c '. ${PYTHON_VENV_PATH}/bin/activate && ./nbconvert.sh' \
	)
#-it $${CONTAINER_ID} /bin/bash -c "find ./ -iname "*.ipynb" | grep -v "_checkpoints" | xargs -I{} jupyter nbconvert --to html {}" \

.PHONY: html_host
html_host: ## Export all jupyter files in root dir as reveal.js slides.html (runs on host)
	( \
		. $(PYTHON_VENV_PATH)/bin/activate; \
		/bin/bash -c "./nbconvert.sh"\
	)
	
# initialize virtual environment in local folder
# This is not needed if docker setup is used
# same as:
# $ virtualenv -p /usr/local/bin/python3.7 venv3.37
# $ source venv3.7/bin/activate
# $ python3.7 -m pip install -r requirements.txt
.PHONY: venv
venv:
	( \
		virtualenv -p /usr/bin/python3 .venv3; \
  	. $(PYTHON_VENV_PATH)/bin/activate; \
		python --version; \
		python3 -m pip install -r requirements.txt; \
	)


