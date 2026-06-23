# shellcheck disable=all

eval "$(starship init zsh)"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"

export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME=""

plugins=(
  git
  archlinux
  zoxide
  starship
  eza
)

# config plugins
zstyle ':omz:plugins:eza' 'icons' yes

source $ZSH/oh-my-zsh.sh
source ~/.config/zsh/alias.sh
source ~/.config/zsh/functions.sh
source ~/.config/zsh/spf.sh
[[ -f $HOME/.cargo/env ]] && source $HOME/.cargo/env
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.config/zsh/yazi.sh

# if [ -z "$ZELLIJ" ]; then
#   zellij
# fi

# opencode
export PATH=/home/eduardo/.opencode/bin:$PATH
export PATH="$HOME/.local/bin:$PATH"
export PATH="/home/eduardo/.bun/bin:$PATH"
export EDITOR=nvim
export DOCKER_HOST=unix:///run/user/$UID/podman/podman.sock
export PATH="$PATH:$(go env GOPATH)/bin"
export ELECTRON_OZONE_PLATFORM_HINT=x11
. "$HOME/.cargo/env"
