#!/usr/bin/env bash
# ==============================================================================
# Login Screen Configuration Script (LightDM + Slick Greeter)
# Dotfiles - Desktop reference for Laptop
# ==============================================================================
set -euo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "Erro: Este script precisa ser executado com privilégios de root (ex: sudo $0)." >&2
    exit 1
fi

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_USER="${SUDO_USER:-$(logname 2>/dev/null || echo "")}"
USER_HOME=""

if [ -n "${TARGET_USER}" ]; then
    USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"
fi

echo "==> [Login Screen] Configurando LightDM e Slick Greeter..."

# 1. Install required packages based on distribution
if command -v dnf >/dev/null 2>&1; then
    echo "==> [Login Screen] Detectado Fedora/RPM. Instalando pacotes necessários..."
    dnf install -y lightdm slick-greeter lightdm-settings
elif command -v apt-get >/dev/null 2>&1; then
    echo "==> [Login Screen] Detectado Debian/Ubuntu. Instalando pacotes necessários..."
    apt-get update -qq
    apt-get install -y lightdm slick-greeter
elif command -v pacman >/dev/null 2>&1; then
    echo "==> [Login Screen] Detectado Arch Linux. Instalando pacotes necessários..."
    pacman -S --noconfirm lightdm lightdm-slick-greeter
else
    echo "==> [Aviso] Gerenciador de pacotes não detectado automaticamente. Certifique-se de instalar 'lightdm' e 'slick-greeter'."
fi

# 2. Configure background wallpaper
echo "==> [Login Screen] Copiando papel de parede para /usr/share/backgrounds/..."
mkdir -p /usr/share/backgrounds
if [ -f "${DOTFILES_DIR}/wallpapers/lofi-background.jpg" ]; then
    cp -f "${DOTFILES_DIR}/wallpapers/lofi-background.jpg" /usr/share/backgrounds/lofi-background.jpg
    chmod 644 /usr/share/backgrounds/lofi-background.jpg
else
    echo "Erro: Wallpaper ${DOTFILES_DIR}/wallpapers/lofi-background.jpg não encontrado!" >&2
    exit 1
fi

# 3. Configure LightDM and Slick Greeter
echo "==> [Login Screen] Instalando configurações em /etc/lightdm/..."
mkdir -p /etc/lightdm/lightdm.conf.d

if [ -f "${DOTFILES_DIR}/lightdm/slick-greeter.conf" ]; then
    cp -f "${DOTFILES_DIR}/lightdm/slick-greeter.conf" /etc/lightdm/slick-greeter.conf
fi

if [ -f "${DOTFILES_DIR}/lightdm/90-slick-greeter.conf" ]; then
    cp -f "${DOTFILES_DIR}/lightdm/90-slick-greeter.conf" /etc/lightdm/lightdm.conf.d/90-slick-greeter.conf
fi

# 4. Make Bibata cursor available for the login screen if found in user home
if [ -n "${USER_HOME}" ] && [ -d "${USER_HOME}/.icons/Bibata-Modern-Ice" ]; then
    echo "==> [Login Screen] Copiando tema Bibata-Modern-Ice para /usr/share/icons/..."
    mkdir -p /usr/share/icons
    cp -rf "${USER_HOME}/.icons/Bibata-Modern-Ice" /usr/share/icons/
fi

# 5. Enable LightDM in systemd
echo "==> [Login Screen] Habilitando serviço lightdm.service..."
systemctl enable lightdm.service

echo "==> [Login Screen] Configuração concluída com sucesso!"
echo "    Para testar a interface do greeter sem reiniciar, execute (como usuário comum):"
echo "    slick-greeter --test-mode"
