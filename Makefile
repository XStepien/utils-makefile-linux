SHELL= /bin/bash

ifneq (,$(wildcard ./.env))
	include .env
	export
endif

# define standard colors
ifneq (,$(findstring xterm,${TERM}))
	BLACK        := $(shell tput -Txterm setaf 0)
	RED          := $(shell tput -Txterm setaf 1)
	GREEN        := $(shell tput -Txterm setaf 2)
	YELLOW       := $(shell tput -Txterm setaf 3)
	LIGHTPURPLE  := $(shell tput -Txterm setaf 4)
	PURPLE       := $(shell tput -Txterm setaf 5)
	BLUE         := $(shell tput -Txterm setaf 6)
	WHITE        := $(shell tput -Txterm setaf 7)
	RESET := $(shell tput -Txterm sgr0)
else
	BLACK        := ""
	RED          := ""
	GREEN        := ""
	YELLOW       := ""
	LIGHTPURPLE  := ""
	PURPLE       := ""
	BLUE         := ""
	WHITE        := ""
	RESET        := ""
endif

TARGET_COLOR := $(LIGHTPURPLE)

RELEASE:= $(shell lsb_release -cs)
USERNAME:= $(shell id -u -n)

VER_NODE?=VER_NODE
VER_ANTLR?=VER_ANTLR
VER_PHP?=VER_PHP

PROMPT_START= @echo "$(GREEN)Installing $(1)...$(RESET)"
PROMPT_END= @echo "$(GREEN)End installing $(1)$(RESET).\n"

.PHONY: git docker-compose docker oh-my-zsh zsh test help

.DEFAULT_GOAL := help

## Hello world
git: ## install git
	$(call PROMPT_START,$@)
	sudo add-apt-repository ppa:git-core/ppa -y
	sudo apt update && sudo apt -y install
	$(call PROMPT_END,$@)

docker-compose: ## install docker-compose
	$(call PROMPT_START,$@)
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(shell uname -s)-$(shell uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose --version
	$(call PROMPT_END,$@)

docker: ## install docker
	$(call PROMPT_START,$@)
	-sudo apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu "$(RELEASE)" stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	@getent group docker || sudo groupadd docker
	sudo usermod -aG docker $(USERNAME)
	$(call PROMPT_END,$@)

oh-my-zsh: zsh ## install zsh
	$(call PROMPT_START,$@)
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install.sh
	chmod +x install.sh
	-sh -c ./install.sh
	rm install.sh
	$(call PROMPT_END,$@)

zsh: ## install zsh and oh-my-zsh
	$(call PROMPT_START,$@)
	sudo apt install zsh -y
	chsh -s $(shell which zsh)
	$(call PROMPT_END,$@)

yarn: nodejs ## install yarn
	$(call PROMPT_START,$@)
	npm install --global yarn
	yarn --version
	mkdir -p ~/.yarn-global
	yarn config set prefix ~/.yarn-global
	sed -i '/^export ZSH=.*/a export PATH="$$HOME/.yarn-global:$$PATH"' ~/.zshrc
	$(/bin/zsh source  ~/.zshrc)
	$(call PROMPT_END,$@)

nodejs: ## install nodeJs
	$(call PROMPT_START,$@)
	curl -fsSL https://deb.nodesource.com/setup_$(VER_NODE).x | sudo -E bash -
	sudo apt-get install -y nodejs
	mkdir -p ~/.npm-packages
	npm config set prefix ~/.npm-packages
	sed -i '/^export ZSH=.*/a export PATH="$$PATH:$$HOME/.npm-packages/bin"' ~/.zshrc
	$(/bin/zsh source  ~/.zshrc)
	$(call PROMPT_END,$@)

java: ## install java
	$(call PROMPT_START,$@)
	sudo apt-get install -y openjdk-8-jre
	java -version
	$(call PROMPT_END,$@)

antlr: java ## install antlr
	$(call PROMPT_START,$@)
	cd /usr/local/lib; sudo curl -O https://www.antlr.org/download/antlr-$(VER_ANTLR)-complete.jar
	sed -i '/^export ZSH=.*/a export CLASSPATH=".:/usr/local/lib/antlr-$(VER_ANTLR)-complete.jar:$$CLASSPATH"' ~/.zshrc
	$(/bin/zsh source  ~/.zshrc)
	$(call PROMPT_END,$@)

install-step-one: git docker zsh ## Full install step 1, need reboot

install-step-two: oh-my-zsh docker-compose yarn antlr  ## Full install step 2, after reboot

help:
	@echo "${WHITE}-----------------------------------------------------------------${RESET}"
	@echo -e "$$(grep -hE '^\S+:.*##' $(MAKEFILE_LIST) | sed -e 's/:.*##\s*/:/' -e 's/^\(.\+\):\(.*\)/\\x1b[36m\1\\x1b[m:\2/' | column -c2 -t -s :)"