{ config, lib, ... }:
{
  options.dotfiles.path = lib.mkOption {
    type = lib.types.str;
    default = "${config.home.homeDirectory}/code/.dotfiles";
    description = ''
      Absolute path of the editable dotfiles checkout. Out-of-store symlinks
      point here so edits apply without a rebuild.
    '';
  };
}
