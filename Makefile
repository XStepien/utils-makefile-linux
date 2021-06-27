#!make
SHELL= /bin/sh

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

PASSWORD?=

ifneq ($(PASSWORD),)
sudo = @echo "$(PASSWORD)" | sudo -S $(1)
else
sudo = @echo "PASSWORD needed" | exit 0
endif

prompt_start= @echo "$(GREEN)Installing $(1)...$(RESET)"
prompt_end= @echo "$(GREEN)End installing $(1)$(RESET).\n"

.PHONY: git docker-compose docker oh-my-zsh zsh test help

.DEFAULT_GOAL := help

## Hello world
git: ## install git
	$(call prompt_start,$@)
	sudo add-apt-repository ppa:git-core/ppa -y
	sudo apt update && sudo apt -y install
	$(call prompt_end,$@)

docker-compose: docker ## install docker-compose
	$(call prompt_start,$@)
	sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(shell uname -s)-$(shell uname -m)" -o /usr/local/bin/docker-compose
	sudo chmod +x /usr/local/bin/docker-compose
	docker-compose --version
	$(call prompt_end,$@)

docker: ## install docker
	$(call prompt_start,$@)
	-sudo apt-get remove docker docker-engine docker.io containerd runc
	sudo apt-get install apt-transport-https ca-certificates curl gnupg lsb-release
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor --yes -o /usr/share/keyrings/docker-archive-keyring.gpg
	echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu "$(RELEASE)" stable' | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	sudo apt-get update
	sudo apt-get install -y docker-ce docker-ce-cli containerd.io
	@getent group docker || sudo groupadd docker
	sudo usermod -aG docker $(USERNAME)
	$(call prompt_end,$@)

oh-my-zsh: zsh ## install zsh
	$(call prompt_start,$@)
	curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh -o install.sh
	chmod +x install.sh
	-sh -c ./install.sh
	rm install.sh
	$(call prompt_end,$@)

zsh: ## install zsh and oh-my-zsh
	$(call prompt_start,$@)
	sudo apt install zsh -y
	chsh -s $(shell which zsh)
	$(call prompt_end,$@)

yarn: nodejs ## install yarn
	$(call prompt_start,$@)
	npm install --global yarn
	yarn --version
	mkdir -p ~/.yarn-global
	yarn config set prefix ~/.yarn-global
	sed -i '/^export ZSH=.*/a export PATH="$$HOME/.yarn-global:$$PATH"' ~/.zshrc
	$(/bin/zsh source  ~/.zshrc)
	$(call prompt_end,$@)

nodejs: ## install nodeJs
	$(call prompt_start,$@)
	curl -fsSL https://deb.nodesource.com/setup_$(VER_NODE).x | sudo -E bash -
	sudo apt-get install -y nodejs
	mkdir -p ~/.npm-packages
	npm config set prefix ~/.npm-packages
	sed -i '/^export ZSH=.*/a export PATH="$$PATH:$$HOME/.npm-packages/bin"' ~/.zshrc
	$(/bin/zsh source  ~/.zshrc)
	$(call prompt_end,$@)

java: ## install java
	$(call prompt_start,$@)
	sudo apt-get install -y openjdk-8-jre
	java -version
	$(call prompt_end,$@)

antlr: java ## install antlr
	$(call prompt_start,$@)
	cd /usr/local/lib; sudo curl -O https://www.antlr.org/download/antlr-$(VER_ANTLR)-complete.jar
	sed -i '/^export ZSH=.*/a export CLASSPATH=".:/usr/local/lib/antlr-$(VER_ANTLR)-complete.jar:$$CLASSPATH"' ~/.zshrc
	$(/bin/zsh source  ~/.zshrc)
	$(call prompt_end,$@)

install-step-one:
	$(call prompt_start,$@)

install-step-two:
	$(call prompt_start,$@)

test:
	@echo 'test => $(VER_PHP)'

help:
	@echo ""
	@echo "${WHITE}-----------------------------------------------------------------${RESET}"
	@grep -E '^[a-zA-Z_0-9%-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "${TARGET_COLOR}%-30s${RESET} %s\n", $$1, $$2}'