# shellcheck disable=all

eval "$(starship init zsh)"

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
  archlinux
  zoxide
  starship
)

source $ZSH/oh-my-zsh.sh
source ~/.config/zsh/alias.sh
source ~/.config/zsh/spf.sh
[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/yazi.sh

# opencode
export PATH=/home/eduardo/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/eduardo/.bun/bin:$PATH"
export EDITOR=nvim
