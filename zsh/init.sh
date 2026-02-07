# shellcheck disable=all

eval "$(starship init zsh)"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
  archlinux
  zoxide
  starship
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh
source ~/.config/zsh/alias.sh
source ~/.config/zsh/spf.sh
source $HOME/.cargo/env

# opencode
export PATH=/home/eduardo/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
