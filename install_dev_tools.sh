#!/usr/bin/env bash
set -e

# Must be run as root
if [ "$(id -u)" -ne 0 ]; then
   echo "Run with sudo"
   exit 1
fi

# Update package list once
apt-get update -y


# Docker
if ! command -v docker >/dev/null 2>&1; then
	apt-get install -y ca-certificates curl gnupg lsb-release


	mkdir -p /etc/apt/keyrings
	curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
	| gpg --dearmor -o /etc/apt/keyrings/docker.gpg

	echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
		  https://download.docker.com/linux/ubuntu \
		  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
		  > /etc/apt/sources.list.d/docker.list

     	apt-get update -y
     	apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

#Python 3

if ! command -v python3 >/dev/null 2>&1 || \
	! python3 -c "import sys; exit(0 if sys.version_info >= (3,9) else 1)"; then
	apt-get install -y python3 python3-pip
fi

#Django

VENV_DIR="./.venv"

#ensure venv + pip exist
apt-get install -y python3-venv python3-pip

if [ ! -d "$VENV_DIR" ]; then
	python3 -m venv "$VENV_DIR"
fi

# install Django only if missing in venv
if ! "$VENV_DIR/bin/python" -c "import django" >/dev/null 2>&1; then
	"$VENV_DIR/bin/pip" install --upgrade pip
	"$VENV_DIR/bin/pip" install django
fi

echo "Installation finished."
