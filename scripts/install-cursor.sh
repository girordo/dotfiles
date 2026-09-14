#!/usr/bin/env bash
# ==============================================================================
# Script de Instalação e Configuração do Cursor Bibata-Modern-Ice
# Dotfiles - Referência do Desktop para Laptop
# ==============================================================================
set -euo pipefail

THEME_NAME="Bibata-Modern-Ice"
ARCHIVE_NAME="${THEME_NAME}.tar.xz"
DOWNLOAD_URL="https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/${ARCHIVE_NAME}"
USER_ICONS_DIR="$HOME/.icons"
USER_LOCAL_ICONS_DIR="$HOME/.local/share/icons"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> [Cursor] Iniciando instalação do tema ${THEME_NAME}..."

# 1. Cria diretórios de ícones do usuário se não existirem
mkdir -p "${USER_ICONS_DIR}"
mkdir -p "${USER_LOCAL_ICONS_DIR}"
mkdir -p "$HOME/.icons/default"
mkdir -p "$HOME/.config/xsettingsd"
mkdir -p "$HOME/.config/gtk-3.0"
mkdir -p "$HOME/.config/gtk-4.0"

# 2. Download e extração do tema caso ainda não esteja instalado
if [ -d "${USER_ICONS_DIR}/${THEME_NAME}" ]; then
    echo "==> [Cursor] O tema ${THEME_NAME} já existe em ${USER_ICONS_DIR}/${THEME_NAME}."
else
    echo "==> [Cursor] Baixando ${THEME_NAME} do GitHub..."
    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "${TMP_DIR}"' EXIT

    if command -v curl >/dev/null 2>&1; then
        curl -sSL "${DOWNLOAD_URL}" -o "${TMP_DIR}/${ARCHIVE_NAME}"
    elif command -v wget >/dev/null 2>&1; then
        wget -q "${DOWNLOAD_URL}" -O "${TMP_DIR}/${ARCHIVE_NAME}"
    else
        echo "Erro: curl ou wget é necessário para baixar o tema." >&2
        exit 1
    fi

    echo "==> [Cursor] Extraindo tema em ${USER_ICONS_DIR}..."
    tar -xf "${TMP_DIR}/${ARCHIVE_NAME}" -C "${USER_ICONS_DIR}"
fi

# 3. Cria symlink para compatibilidade com XDG Data Dirs
if [ ! -e "${USER_LOCAL_ICONS_DIR}/${THEME_NAME}" ]; then
    echo "==> [Cursor] Criando symlink em ${USER_LOCAL_ICONS_DIR}/${THEME_NAME}..."
    ln -s "${USER_ICONS_DIR}/${THEME_NAME}" "${USER_LOCAL_ICONS_DIR}/${THEME_NAME}"
fi

# 4. Aplica arquivos de configuração do dotfiles
echo "==> [Cursor] Aplicando configurações do dotfiles..."

# index.theme default
if [ -f "${DOTFILES_DIR}/icons/default/index.theme" ]; then
    cp -f "${DOTFILES_DIR}/icons/default/index.theme" "$HOME/.icons/default/index.theme"
fi

# xsettingsd
if [ -f "${DOTFILES_DIR}/xsettingsd/xsettingsd.conf" ]; then
    cp -f "${DOTFILES_DIR}/xsettingsd/xsettingsd.conf" "$HOME/.config/xsettingsd/xsettingsd.conf"
fi

# GTK 3.0 e 4.0
if [ -f "${DOTFILES_DIR}/gtk-3.0/settings.ini" ]; then
    cp -f "${DOTFILES_DIR}/gtk-3.0/settings.ini" "$HOME/.config/gtk-3.0/settings.ini"
fi
if [ -f "${DOTFILES_DIR}/gtk-4.0/settings.ini" ]; then
    cp -f "${DOTFILES_DIR}/gtk-4.0/settings.ini" "$HOME/.config/gtk-4.0/settings.ini"
fi

# .Xresources
if [ -f "${DOTFILES_DIR}/.Xresources" ]; then
    cp -f "${DOTFILES_DIR}/.Xresources" "$HOME/.Xresources"
    if command -v xrdb >/dev/null 2>&1 && [ -n "${DISPLAY:-}" ]; then
        xrdb -merge "$HOME/.Xresources" 2>/dev/null || true
    fi
fi

# .profile (variáveis de ambiente XCURSOR)
if [ -f "${DOTFILES_DIR}/.profile" ]; then
    if [ ! -f "$HOME/.profile" ]; then
        cp "${DOTFILES_DIR}/.profile" "$HOME/.profile"
    else
        if ! grep -q "XCURSOR_THEME" "$HOME/.profile"; then
            echo "" >> "$HOME/.profile"
            cat "${DOTFILES_DIR}/.profile" >> "$HOME/.profile"
        fi
    fi
fi

# 5. Opcional: Instalação no sistema (/usr/share/icons) para a tela de login (LightDM)
if [ "${1:-}" = "--system" ] || [ "$(id -u)" -eq 0 ]; then
    echo "==> [Cursor] Instalando tema no sistema (/usr/share/icons/)..."
    if [ "$(id -u)" -eq 0 ]; then
        cp -r "${USER_ICONS_DIR}/${THEME_NAME}" /usr/share/icons/
    else
        sudo cp -r "${USER_ICONS_DIR}/${THEME_NAME}" /usr/share/icons/
    fi
    echo "==> [Cursor] Tema instalado em /usr/share/icons/${THEME_NAME}."
else
    echo "==> [Dica] Para disponibilizar o cursor também na tela de login (LightDM), execute:"
    echo "    sudo cp -r ${USER_ICONS_DIR}/${THEME_NAME} /usr/share/icons/"
    echo "    ou execute: ./scripts/install-cursor.sh --system"
fi

echo "==> [Cursor] Instalação e configuração concluídas com sucesso!"
