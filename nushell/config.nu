# Interactive Nushell configuration.

# Official zoxide integration for Nushell.
source ~/.zoxide.nu

source ($nu.default-config-dir | path join "alias.nu")

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
let starship_init = ($nu.data-dir | path join "vendor/autoload" "starship.nu")
mkdir ($starship_init | path dirname)
starship init nu | save -f $starship_init
