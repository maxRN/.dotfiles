{
  config,
  lib,
  pkgs,
  ...
}:
{
  # Rex puts its CLI's directory first in PATH (and in REX_BIN_DIR) in every
  # terminal it opens; nix-darwin's shell init resets PATH, so move it back.
  # https://www.superlogical.com/rex/docs/automate/cli#path
  # shellInit, not interactiveShellInit: `rex run` blocks are non-interactive.
  programs.fish.shellInit = lib.mkOrder 2000 ''
    if set -q REX_BIN_DIR; and test -n "$REX_BIN_DIR"
      fish_add_path --path --prepend --move "$REX_BIN_DIR"
    end
  '';

  # Rex port of tmux-sessionizer. The sessionizer action in init.lua runs it in
  # a floating layer; rex itself comes from REX_BIN_DIR on PATH.
  home.packages = [
    (pkgs.writeShellApplication {
      name = "rex-sessionizer";
      runtimeInputs = [
        pkgs.fzf
        pkgs.jq
      ];
      text = ''
        if [[ $# -eq 1 ]]; then
            selected=$1
        else
            # A missing directory or a cancelled fzf just means "nothing selected".
            selected=$(find ~/work ~/code ~/uni ~/notes -mindepth 1 -maxdepth 1 -type d 2> /dev/null | fzf --color gutter:-1) || true
        fi

        if [[ -z $selected ]]; then
            exit 0
        fi

        selected_name=$(basename "$selected")

        session_id=$(rex ls --json | jq -r --arg name "$selected_name" 'first(.sessions[] | select(.label == $name) | .session_id) // empty')
        if [[ -z $session_id ]]; then
            session_id=$(rex new "$selected_name" -c "$selected" --json | jq -r .session_id)
        fi

        # The sessionizer action sets REX_CLIENT, so this switches the app that
        # opened the picker even when several are connected.
        rex "do" session.select session_id="$session_id"
      '';
    })
  ];

  home.file.".config/rex".source =
    config.lib.file.mkOutOfStoreSymlink "${config.dotfiles.path}/home/dotfiles/rex";
}
