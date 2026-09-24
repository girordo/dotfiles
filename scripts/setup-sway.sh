#!/usr/bin/env bash
# ==============================================================================
# Script de Instalação e Configuração do Sway e Waybar
# Dotfiles - Migração de i3 para Sway (Wayland)
# ==============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"

echo "==> [Sway Setup] Iniciando instalação e configuração do ambiente Wayland..."

# 1. Instalação de pacotes
if command -v dnf >/dev/null 2>&1; then
    echo "==> [Sway Setup] Detectado Fedora/RPM. Instalando pacotes necessários via dnf..."
    sudo dnf install -y \
        sway \
        waybar \
        swaybg \
        swayidle \
        swaylock \
        rofi \
        cliphist \
        wl-clipboard \
        grim \
        slurp \
        gammastep \
        brightnessctl \
        pavucontrol \
        network-manager-applet \
        dunst \
        playerctl

    # Instalação do SwayFX para animações, blur, sombras e cantos arredondados
    if [[ "${1:-}" == "--fx" ]] || [[ "${INSTALL_FX:-}" == "1" ]]; then
        echo "==> [SwayFX Setup] Habilitando repositório COPR e instalando SwayFX..."
        sudo dnf copr enable -y swayfx/swayfx || sudo dnf copr enable -y mochaa/swayfx
        sudo dnf swap -y sway swayfx
    fi
elif command -v apt-get >/dev/null 2>&1; then
    echo "==> [Sway Setup] Detectado Debian/Ubuntu. Instalando pacotes necessários via apt..."
    sudo apt-get update -qq
    sudo apt-get install -y \
        sway \
        waybar \
        swaybg \
        swayidle \
        swaylock \
        cliphist \
        wl-clipboard \
        grim \
        slurp \
        gammastep \
        brightnessctl \
        pavucontrol \
        network-manager-gnome \
        dunst \
        playerctl
elif command -v pacman >/dev/null 2>&1; then
    echo "==> [Sway Setup] Detectado Arch Linux. Instalando pacotes necessários via pacman..."
    sudo pacman -S --noconfirm --needed \
        sway \
        waybar \
        swaybg \
        swayidle \
        swaylock \
        rofi-wayland \
        cliphist \
        wl-clipboard \
        grim \
        slurp \
        gammastep \
        brightnessctl \
        pavucontrol \
        network-manager-applet \
        dunst \
        playerctl
else
    echo "==> [Aviso] Gerenciador de pacotes não identificado. Certifique-se de instalar manualmente:"
    echo "    sway, waybar, swaybg, swayidle, swaylock, rofi-wayland, cliphist, wl-clipboard, grim, slurp, gammastep, dunst"
fi

# 2. Configurando diretórios em ~/.config
echo "==> [Sway Setup] Criando diretórios de configuração..."
mkdir -p "${USER_HOME}/.config/sway"
mkdir -p "${USER_HOME}/.config/waybar"
mkdir -p "${USER_HOME}/Pictures/wallpaper"

# 3. Criando links simbólicos para as configurações
echo "==> [Sway Setup] Aplicando links simbólicos..."
ln -sf "${DOTFILES_DIR}/sway/config" "${USER_HOME}/.config/sway/config"
ln -sf "${DOTFILES_DIR}/waybar/config.jsonc" "${USER_HOME}/.config/waybar/config.jsonc"
ln -sf "${DOTFILES_DIR}/waybar/style.css" "${USER_HOME}/.config/waybar/style.css"

# 4. Assegurar wallpaper padrão em ~/Pictures/wallpaper se não existir
if [ -f "${DOTFILES_DIR}/wallpapers/lofi-background.jpg" ]; then
    if [ ! -f "${USER_HOME}/Pictures/wallpaper/lofi-background.jpg" ]; then
        echo "==> [Sway Setup] Copiando papel de parede padrão..."
        cp -f "${DOTFILES_DIR}/wallpapers/lofi-background.jpg" "${USER_HOME}/Pictures/wallpaper/lofi-background.jpg"
    fi
fi

echo "==> [Sway Setup] Configuração do Sway e Waybar concluída com sucesso!"
echo "    Você já pode selecionar a sessão 'Sway' na tela de login (LightDM / GDM) ou rodar 'sway' a partir de um TTY."
