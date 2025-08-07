{ config, lib, ... }:
let
  cfg = config.services.kanata;
in
{
  options.services.kanata = {
    enable = lib.mkEnableOption "Enable kanata service";
    user = lib.mkOption {
      type = lib.types.str;
      example = "\${config.home.username}";
      description = "The username where";
    };
    pkg = lib.mkOption {
      type = lib.types.str;
      example = "/etc/profiles/per-user/${cfg.user}/bin/kanata";
      description = "Kanata package to use";
      default = "/etc/profiles/per-user/${cfg.user}/bin/kanata";
    };
    configs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Config files to use.";
      example = "[ \"config.user.\${config.home.username}/.config/kanata/macbook.kbd\" ]";
    };
  };
  config =
    let
      config_args = builtins.concatMap (config: [
        "--cfg"
        config
      ]) cfg.configs;
    in
    lib.mkIf cfg.enable {
      launchd.daemons.kanata-nix = {
        command = "${cfg.pkg} ${builtins.toString config_args}";
        # path = [ cfg.pkg ];
        serviceConfig = {
          Label = "org.nix-darwin.kanata";
          KeepAlive = true;
          RunAtLoad = true;
          StandardOutPath = "/var/log/nix/kanata/stdout.log";
          StandardErrorPath = "/var/log/nix/kanata/stderr.log";
        };
      };
    };
}
