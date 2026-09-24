#!/usr/bin/env bash
# ==============================================================================
# Script to install Swayfx
# Dotfiles - Migration from i3 to Swayfx (Wayland)
# ==============================================================================
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_USER="${SUDO_USER:-$USER}"
USER_HOME="$(getent passwd "${TARGET_USER}" | cut -d: -f6)"

echo "==> [Sway Setup] Iniciando instalação e configuração do ambiente Wayland..."

# 1. Package install
if command -v dnf >/dev/null 2>&1; then
  echo "==> [Sway Setup] Detectado Fedora/RPM. Instalando pacotes necessários via dnf..."

  # Detects Fedora version
  FEDORA_VERSION=$(grep -E '^VERSION_ID=' /etc/os-release | tr -d '"' | cut -d= -f2)

  # Common packages
  BASE_PKGS=(
    waybar
    swaybg
    swayidle
    swaylock
    rofi
    cliphist
    wl-clipboard
    grim
    slurp
    gammastep
    brightnessctl
    pavucontrol
    network-manager-applet
    dunst
    playerctl
  )

  if [[ "${FEDORA_VERSION:-0}" -ge 44 ]]; then
    echo "==> [SwayFX Setup] Fedora 44+ detectado (v${FEDORA_VERSION}). Habilitando repositório e instalando SwayFX..."
    sudo dnf copr enable -y swayfx/swayfx || sudo dnf copr enable -y mochaa/swayfx
    sudo dnf install -q -y swayfx "${BASE_PKGS[@]}" --allowerasing
  else
    echo "==> [Sway Setup] Fedora ${FEDORA_VERSION} detectado. A versão mais recente do SwayFX requer Fedora 44+. Instalando Sway padrão..."
    sudo dnf install -q -y sway "${BASE_PKGS[@]}"
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

# 2. Set up directories in ~/.config
echo "==> [Sway Setup] Criando diretórios de configuração..."
mkdir -p "${USER_HOME}/.config/sway"
mkdir -p "${USER_HOME}/.config/waybar"
mkdir -p "${USER_HOME}/Pictures/wallpaper"

# 3. Create symlinks for configuration files
echo "==> [Sway Setup] Aplicando links simbólicos..."
ln -sf "${DOTFILES_DIR}/sway/config" "${USER_HOME}/.config/sway/config"
ln -sf "${DOTFILES_DIR}/waybar/config.jsonc" "${USER_HOME}/.config/waybar/config.jsonc"
ln -sf "${DOTFILES_DIR}/waybar/style.css" "${USER_HOME}/.config/waybar/style.css"

# 4. Ensure default wallpaper in ~/Pictures/wallpaper if not present
if [ -f "${DOTFILES_DIR}/wallpapers/lofi-background.jpg" ]; then
  if [ ! -f "${USER_HOME}/Pictures/wallpaper/lofi-background.jpg" ]; then
    echo "==> [Sway Setup] Copiando papel de parede padrão..."
    cp -f "${DOTFILES_DIR}/wallpapers/lofi-background.jpg" "${USER_HOME}/Pictures/wallpaper/lofi-background.jpg"
  fi
fi

echo "==> [Sway Setup] Configuração do Sway e Waybar concluída com sucesso!"
echo "    Você já pode selecionar a sessão 'Sway' na tela de login (LightDM / GDM) ou rodar 'sway' a partir de um TTY."
