#!/usr/bin/env bash
set -euo pipefail

step() { echo -e "\n==> $1"; }

DOTFILES_DIR="$HOME/.dotfiles"

if [ "$EUID" -eq 0 ]; then
  echo "✗ Do not run bootstrap as root"
  exit 1
fi

step "Ensuring stow is installed"
if ! command -v stow >/dev/null 2>&1; then
  sudo pacman -S --noconfirm --needed stow
fi

step "Cloning or updating dotfiles repo"
if [ -d "$DOTFILES_DIR/.git" ]; then
  git -C "$DOTFILES_DIR" pull --ff-only || true
else
  git clone https://github.com/minipog/dotfiles "$DOTFILES_DIR"
fi

step "Applying dotfile packages"
cd "$DOTFILES_DIR"
stow zsh git editorconfig
mkdir -p "$HOME/.config/gh"
stow --target="$HOME/.config/gh" gh

step "Installing developer packages"
PKGS=(neovim lazygit fzf ripgrep fd bat unzip wget nodejs npm python-pynvim wl-clipboard xclip)
sudo pacman -S --noconfirm --needed "${PKGS[@]}"

step "Setting up Neovim config"
if [ ! -d "$HOME/.config/nvim" ]; then
  git clone --depth=1 https://github.com/LazyVim/starter "$HOME/.config/nvim"
  rm -rf "$HOME/.config/nvim/.git"
else
  echo "• Neovim config already present, skipping."
fi
