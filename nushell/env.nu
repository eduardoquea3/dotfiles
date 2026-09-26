# Environment configuration for Nushell.

$env.ANDROID_HOME = ($env.HOME | path join "Android" "Sdk")
$env.EDITOR = "nvim"
$env.ELECTRON_OZONE_PLATFORM_HINT = "x11"

let uid = (^id -u | str trim)
$env.DOCKER_HOST = $"unix:///run/user/($uid)/podman/podman.sock"

# Official zoxide integration for Nushell.
zoxide init nushell | save -f ~/.zoxide.nu

# Match the paths loaded by zsh/init.sh, keeping user tools ahead of system
# binaries and avoiding duplicate entries inherited from the parent shell.
let brew_prefix = "/home/linuxbrew/.linuxbrew"
let brew_paths = if (($brew_prefix | path join "bin" "brew") | path exists) {
    $env.HOMEBREW_PREFIX = $brew_prefix
    $env.HOMEBREW_CELLAR = ($brew_prefix | path join "Cellar")
    $env.HOMEBREW_REPOSITORY = ($brew_prefix | path join "Homebrew")
    [
        ($brew_prefix | path join "bin")
        ($brew_prefix | path join "sbin")
    ]
} else {
    []
}

let user_paths = [
    ($env.HOME | path join ".opencode" "bin")
    ($env.HOME | path join ".local" "bin")
    ($env.HOME | path join ".bun" "bin")
    ($env.HOME | path join ".cargo" "bin")
    ($env.ANDROID_HOME | path join "emulator")
    ($env.ANDROID_HOME | path join "platform-tools")
]

let system_paths = [
    "/usr/local/sbin"
    "/usr/local/bin"
    "/usr/sbin"
    "/usr/bin"
    "/sbin"
    "/bin"
]

$env.PATH = ($env.PATH | prepend ($user_paths ++ $brew_paths ++ $system_paths) | uniq)

# Go-installed binaries are normally outside the system PATH.
if (which go | is-not-empty) {
    let go_bin = (^go env GOPATH | str trim | path join "bin")
    $env.PATH = ($env.PATH | append $go_bin | uniq)
}
