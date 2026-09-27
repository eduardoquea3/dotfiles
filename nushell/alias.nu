# Aliases migrated from ~/.config/zsh/alias.sh.

# Nushell cannot alias the `source` keyword, so restart the shell instead.
alias ss = exec nu
alias ns = nvim $nu.config-path
alias nsa = nvim ($nu.default-config-dir | path join "alias.nu")
alias nse = nvim $nu.default-config-dir
alias cls = clear

alias dev = just dev
alias lg = lazygit
alias ld = lazydocker

alias i = impala
alias bt = bluetui
alias wm = wiremix

alias pd = podman
alias pdu = podman-tui

# Arch Linux package management aliases from the Zsh archlinux plugin.
alias pacin = sudo pacman -S
alias pacupd = sudo pacman -Sy
alias pacupg = sudo pacman -Syu
alias yain = yay -S
alias yaupd = yay -Sy
alias yaupg = yay -Syu

alias cc = codex
alias op = opencode
alias cupd = claude update

alias nv = nvim
alias vim = nvim
alias ze = zellij
alias cd = z
