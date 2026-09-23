# Interactive Nushell configuration.

# Official zoxide integration for Nushell.
source ~/.zoxide.nu

# Aliases migrated from ~/.config/zsh/alias.sh.
def ss [] { exec nu }
alias ns = nvim $nu.config-path
alias nsa = nvim $nu.config-path
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

def zo [directory?: path] {
    let root = ($directory | default ".")
    let pdf = (
        ^find $root -name "*.pdf" -type f
        | ^fzf --preview "file {}"
        | str trim
    )

    if not ($pdf | is-empty) {
        job spawn { ^zathura $pdf }
    }
}

def --env --wrapped y [...args: string] {
    let tmp = (^mktemp -t "yazi-cwd.XXXXXX" | str trim)
    ^yazi ...$args --cwd-file $tmp

    if ($tmp | path exists) {
        let cwd = (open $tmp | str trim)
        rm -f -- $tmp

        if ($cwd != $env.PWD and ($cwd | path type) == "dir") {
            cd $cwd
        }
    }
}

def --env --wrapped spf [...args: string] {
    let cwd = (^spf ...$args --print-last-dir | str trim)

    if ($cwd | path exists) and (($cwd | path type) == "dir") {
        cd $cwd
    }
}

# Official Starship integration for Nushell.
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")
