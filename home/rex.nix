{
  config,
  lib,
  pkgs,
  ...
}:
let
  restoreRexPath = ''
    if [ -n "''${REX_BIN_DIR:-}" ]; then
      export PATH="$REX_BIN_DIR:$PATH"
    fi
  '';
in
{
  # Rex supplies the CLI matching the running server. Restore it after Nix and
  # shell startup have changed PATH, rather than pinning an app bundle location.
  # https://www.superlogical.com/rex/docs/automate/cli#path
  programs.fish.interactiveShellInit = lib.mkOrder 2000 ''
    if set -q REX_BIN_DIR; and test -n "$REX_BIN_DIR"
      fish_add_path --path --prepend --move "$REX_BIN_DIR"
    end
  '';
  programs.bash.initExtra = lib.mkAfter restoreRexPath;
  programs.zsh.initContent = lib.mkAfter restoreRexPath;

  home.packages = [
    (pkgs.writeShellScriptBin "rex-sessionizer" ''
      exec ${config.home.homeDirectory}/.config/rex/sessionizer "$@"
    '')
  ];

  home.file = {
    ".config/rex".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/.dotfiles/home/dotfiles/rex";

    # Fallback for terminals outside Rex and the standalone launchd server.
    # Rex moves its CLI between releases, so resolve it at run time. Exec by
    # absolute path: the app binary can't find its frameworks through a symlink.
    ".local/bin/rex" = {
      executable = true;
      force = true;
      text = ''
        #!/bin/sh
        for rex in \
          "''${REX_BIN_DIR:+$REX_BIN_DIR/rex}" \
          "$HOME/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/Rex Server.app/Contents/MacOS/rex" \
          "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.app/Contents/MacOS/rex" \
          "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex"; do
          if [ -n "$rex" ] && [ -x "$rex" ]; then exec "$rex" "$@"; fi
        done
        echo "rex: no Rex CLI found; is Rex Beta.app installed?" >&2
        exit 127
      '';
    };
  };
}
