# Environment configuration for Nushell.

$env.ANDROID_HOME = ($env.HOME | path join "Android" "Sdk")
$env.EDITOR = "nvim"
$env.ELECTRON_OZONE_PLATFORM_HINT = "x11"

let uid = (^id -u | str trim)
$env.DOCKER_HOST = $"unix:///run/user/($uid)/podman/podman.sock"

# Official zoxide integration for Nushell.
zoxide init nushell | save -f ~/.zoxide.nu

# Keep user-installed tools before system binaries, while retaining the
# standard Arch Linux and Homebrew locations.
$env.PATH = (
    $env.PATH
    | prepend [
        ($env.HOME | path join ".cargo" "bin")
        ($env.HOME | path join ".local" "bin")
        ($env.HOME | path join ".opencode" "bin")
        ($env.HOME | path join ".bun" "bin")
        ($env.ANDROID_HOME | path join "emulator")
        ($env.ANDROID_HOME | path join "platform-tools")
        "/home/linuxbrew/.linuxbrew/bin"
        "/home/linuxbrew/.linuxbrew/sbin"
        "/usr/local/bin"
        "/usr/local/sbin"
        "/usr/bin"
        "/usr/sbin"
        "/bin"
        "/sbin"
    ]
    | uniq
)

# Go-installed binaries are normally outside the system PATH.
if (which go | is-not-empty) {
    let go_bin = (^go env GOPATH | str trim | path join "bin")
    $env.PATH = ($env.PATH | prepend $go_bin | uniq)
}
