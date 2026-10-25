{
  config,
  lib,
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

  home.file.".config/rex".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/code/.dotfiles/home/dotfiles/rex";
}
