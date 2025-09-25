#!/usr/bin/env bash
set -euo pipefail

step() { echo -e "\n==> $1"; }

USERNAME="minipog"
REPO_URL="https://github.com/minipog/dotfiles"

step "Configuring locale"
sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen
echo 'LANG=en_US.UTF-8' > /etc/locale.conf
ln -sf /etc/locale.conf /etc/default/locale

step "Initializing pacman"
pacman-key --init
pacman-key --populate archlinux
pacman -Syu --noconfirm
pacman -S --noconfirm --needed base base-devel sudo zsh git github-cli

step "Creating user $USERNAME"
if ! id -u "$USERNAME" &>/dev/null; then
  useradd -m -G wheel -s /bin/zsh "$USERNAME"
  echo "%wheel ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/wheel
  chmod 440 /etc/sudoers.d/wheel
fi

step "Configuring WSL default user"
cat >/etc/wsl.conf <<EOF
[boot]
systemd=true

[user]
default=$USERNAME
EOF

step "Cloning or updating dotfiles repo"
if [ -d "/home/$USERNAME/.dotfiles/.git" ]; then
  sudo -u "$USERNAME" git -C "/home/$USERNAME/.dotfiles" pull --ff-only || true
else
  sudo -u "$USERNAME" git clone "$REPO_URL" "/home/$USERNAME/.dotfiles"
fi

step "Running bootstrap.sh as $USERNAME"
sudo -u "$USERNAME" bash "/home/$USERNAME/.dotfiles/scripts/bootstrap.sh"

step "✔ Install complete"
