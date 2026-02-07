# shellcheck disable=all

# Load Zed secrets
source $HOME/.secrets/zed.env 2>/dev/null

alias ss='source ~/.zshrc'
alias ns='nvim ~/.zshrc'
alias nsa='nvim ~/.config/zsh/alias.sh'
alias nse='nvim ~/.config/zsh/'
alias cls='clear'

alias ls='eza --icons'
alias la='eza --icons -a'

alias dev='just dev'

alias lg='lazygit'
alias ld='lazydocker'

alias i='impala'
alias bt='bluetui'
alias wm='wiremix'

alias pd='podman'
alias cc='claude'
alias op='opencode'
alias cupd='claude update'
