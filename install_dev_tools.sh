#!/usr/bin/env bash
set -e

# Run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Run with sudo"
  exit 1
fi

apt-get update -y

# Docker + Docker Compose plugin
if ! command -v docker >/dev/null 2>&1; then
  apt-get install -y ca-certificates curl gnupg lsb-release

  mkdir -p /etc/apt/keyrings
  curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  chmod a+r /etc/apt/keyrings/docker.gpg

  echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu \
$(. /etc/os-release && echo "$VERSION_CODENAME") stable" \
  > /etc/apt/sources.list.d/docker.list

  apt-get update -y
  apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
fi

# If docker exists but compose plugin is missing
if ! docker compose version >/dev/null 2>&1; then
  apt-get install -y docker-compose-plugin
fi

# Python 3.9+
if ! command -v python3 >/dev/null 2>&1 || \
   ! python3 -c "import sys; exit(0 if sys.version_info >= (3,9) else 1)"; then
  apt-get install -y python3 python3-pip
fi

# pip
if ! command -v pip3 >/dev/null 2>&1; then
  apt-get install -y python3-pip
fi

# Django
if ! python3 -c "import django" >/dev/null 2>&1; then
  pip3 install --upgrade pip
  pip3 install django || pip3 install django --break-system-packages
fi

echo "Installation finished."
docker --version 2>/dev/null || true
docker compose version 2>/dev/null || true
python3 --version 2>/dev/null || true
python3 -c "import django; print('Django', django.get_version())" 2>/dev/null || true
