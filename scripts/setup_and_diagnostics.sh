#!/usr/bin/env bash
set -euo pipefail

NEW_USER="${1:-devops}"
USER_PASS="${2:-Dev_Ops2026!}"

echo "=== 1. Обновление индексов и установка базовых пакетов ==="
sudo apt update
sudo apt install -y openssh-server traceroute python3 python-is-python3 git

echo "=== 2. Запуск и проверка SSH-сервера ==="
sudo systemctl enable --now ssh
sudo systemctl status ssh --no-pager

echo "=== 3. Диагностика ОС, дисков и прав доступа ==="
uname -a
lsb_release -a
top -b -n 1 | head -n 15
ls -la /
lsblk
sudo fdisk -l
mount | head -n 20

mkdir -p ~/lab01_test && touch ~/lab01_test/sample.txt
chmod 750 ~/lab01_test
chmod 600 ~/lab01_test/sample.txt
sudo chown "$USER:$USER" ~/lab01_test/sample.txt
ls -la ~/lab01_test

echo "=== 4. Диагностика сети ==="
ip addr
traceroute -m 10 1.1.1.1 || true

echo "=== 5. Создание пользователя $NEW_USER с домашним каталогом и беспарольным sudo ==="
if ! id "$NEW_USER" &>/dev/null; then
    sudo useradd -m -s /bin/bash -G sudo "$NEW_USER"
    echo "${NEW_USER}:${USER_PASS}" | sudo chpasswd
fi

echo "${NEW_USER} ALL=(ALL) NOPASSWD:ALL" | sudo tee "/etc/sudoers.d/${NEW_USER}" > /dev/null
sudo chmod 440 "/etc/sudoers.d/${NEW_USER}"
sudo visudo -c

sudo mkdir -p "/home/${NEW_USER}/.ssh"
sudo touch "/home/${NEW_USER}/.ssh/authorized_keys"
sudo chown -R "${NEW_USER}:${NEW_USER}" "/home/${NEW_USER}/.ssh"
sudo chmod 700 "/home/${NEW_USER}/.ssh"
sudo chmod 600 "/home/${NEW_USER}/.ssh/authorized_keys"

echo "=== Готово. Поместите публичный ключ в /home/${NEW_USER}/.ssh/authorized_keys ==="
