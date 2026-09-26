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
alias cc = codex
alias op = opencode
alias cupd = claude update

alias nv = nvim
alias vim = nvim
alias ze = zellij
alias cd = z
