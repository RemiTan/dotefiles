#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Helper function for printing headers
header() {
  echo -e "\n\033[1;34m==> $1\033[0m"
}

# Install Homebrew if not installed
if ! command -v brew &>/dev/null; then
  header "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
  header "Homebrew already installed"
fi

header "Updating Homebrew..."
brew update

header "Installing CLI tools..."
brew install fzf fd starship eza bat zsh

# Install zsh plugins
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

header "Installing oh-my-zsh if not installed..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "oh-my-zsh already installed"
fi

header "Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || echo "zsh-autosuggestions already exists"

header "Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || echo "zsh-syntax-highlighting already exists"

# fzf post-install
header "Installing fzf key bindings and completion..."
"$(brew --prefix)/opt/fzf/install" --all --no-bash --no-fish

# Update .zshrc
ZSHRC="$HOME/.zshrc"

header "Updating .zshrc..."

add_to_zshrc() {
  grep -qxF "$1" "$ZSHRC" || echo "$1" >>"$ZSHRC"
}

add_to_zshrc 'export PATH="$HOME/bin:$PATH"'
add_to_zshrc 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting)'
add_to_zshrc 'source $ZSH/oh-my-zsh.sh'
add_to_zshrc 'eval "$(starship init zsh)"'

header "Done! Reload your shell or run: source ~/.zshrc"

