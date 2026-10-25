# Remote update path for ohnezahn, meant to be run over SSH. Steps that can drop
# the connection say so and ask first.
#
#   ohnezahn-update status                 # what is outdated (macOS, brew, mas)
#   ohnezahn-update nix [--pull] [--to laptop|server]
#   ohnezahn-update brew                   # formulae + casks (--greedy), except tailscale
#   ohnezahn-update tailscale              # brew upgrade + restart tailscaled (drops Tailscale SSH)
#   ohnezahn-update mas                    # App Store apps
#   ohnezahn-update macos                  # softwareupdate --stdinpass, restarts
#   ohnezahn-update reboot                 # fdesetup authrestart (skips the FileVault unlock)

flake=${OHNEZAHN_FLAKE:-$HOME/code/.dotfiles}
profile=$(cat /etc/ohnezahn/profile)
brew=/opt/homebrew/bin/brew

attr_for() { if [ "$1" = server ]; then echo ohnezahn-server; else echo ohnezahn; fi; }
confirm() {
  local answer
  read -r -p "$1 [y/N] " answer
  [ "$answer" = y ] || [ "$answer" = Y ]
}

cmd=${1:-status}
[ $# -gt 0 ] && shift

case "$cmd" in
  status)
    echo "profile: $profile (nix switches use .#$(attr_for "$profile"))"
    echo "== macOS"; softwareupdate --list || true
    echo "== brew";  "$brew" outdated --greedy || true
    echo "== mas";   if command -v mas >/dev/null; then mas outdated || true; fi
    ;;

  nix)
    target=$profile
    while [ $# -gt 0 ]; do
      case "$1" in
        --pull) git -C "$flake" pull --ff-only; shift ;;
        --to) target=$2; shift 2 ;;
        *) echo "unknown nix option: $1" >&2; exit 64 ;;
      esac
    done
    attr=$(attr_for "$target")
    out="$(mktemp -d)/system"
    nix build "$flake#darwinConfigurations.$attr.system" -o "$out"
    nvd diff /run/current-system "$out"
    # A plain `darwin-rebuild switch --flake .` picks #ohnezahn by hostname, so
    # it would silently leave server mode. Always name the attribute.
    confirm "switch to .#$attr ($target)?" || exit 1
    sudo darwin-rebuild switch --flake "$flake#$attr"
    ohnezahn-check || true
    ;;

  brew)
    "$brew" update
    mapfile -t outdated < <("$brew" outdated --greedy --quiet | grep -vx tailscale || true)
    if [ ${#outdated[@]} -eq 0 ]; then echo "nothing to upgrade"; exit 0; fi
    printf '  %s\n' "${outdated[@]}"
    echo "Casks of running apps (Dropbox, Chrome, ...) get quit and replaced."
    confirm "upgrade these?" || exit 1
    "$brew" upgrade --greedy "${outdated[@]}"
    ;;

  tailscale)
    "$brew" update
    "$brew" outdated tailscale || { echo "tailscale is current"; exit 0; }
    echo "Restarting tailscaled drops every Tailscale SSH session, probably this one."
    echo "Run this from the sshd fallback, or accept a ~10 s reconnect."
    confirm "upgrade and restart tailscaled?" || exit 1
    sudo -v
    "$brew" upgrade tailscale
    sudo launchctl kickstart -k system/homebrew.mxcl.tailscale
    ;;

  mas)
    mas outdated
    confirm "upgrade App Store apps?" || exit 1
    mas upgrade
    ;;

  macos)
    softwareupdate --list
    echo "Installs ALL updates and restarts. Whether that restart skips the FileVault"
    echo "unlock screen is unverified; if ohnezahn doesn't return on Tailscale within"
    echo "~20 min, unlock it with SSH over the LAN (docs/ohnezahn-server.md)."
    confirm "install and restart?" || exit 1
    sudo -v
    read -r -s -p "password for $USER (softwareupdate --stdinpass): " pw
    echo
    printf '%s\n' "$pw" | sudo softwareupdate --install --all --restart --stdinpass --user "$USER"
    ;;

  reboot)
    echo "Authenticated restart: skips the FileVault unlock. If it lands on the login"
    echo "window, agents, Dropbox and Simulator stay down until a GUI login (Screen Sharing)."
    confirm "restart now?" || exit 1
    sudo fdesetup authrestart -delayminutes 0
    ;;

  *)
    echo "usage: ohnezahn-update status|nix [--pull] [--to laptop|server]|brew|tailscale|mas|macos|reboot" >&2
    exit 64
    ;;
esac
