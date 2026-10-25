{
  config,
  lib,
  pkgs,
  ...
}:
let
  home = config.home.homeDirectory;
  varlock = "${home}/.local/bin/varlock";
  logDirectory = "${home}/Library/Logs/varlock";
  services = {
    varlock-proxy = {
      WorkingDirectory = "${home}/.config/varlock/loki";
      ProgramArguments = [
        varlock
        "proxy"
        "start"
      ];
    };
    uat-db-helper = {
      WorkingDirectory = "${home}/.config/varlock/uat-db";
      ProgramArguments = [
        varlock
        "run"
        "--inject"
        "vars"
        "--"
        "${home}/.config/varlock/uat-db/.venv/bin/python"
        "${home}/.config/varlock/uat-db/server.py"
      ];
    };
  };
in
{
  launchd.agents = lib.mapAttrs (name: service: {
    enable = true;
    config = {
      Label = "com.maxrn.${name}";
      RunAtLoad = true;
      KeepAlive = true;
      ThrottleInterval = 30;
      ProcessType = "Background";
      Umask = 63;
      ExitTimeOut = 15;
      StandardOutPath = "${logDirectory}/com.maxrn.${name}.log";
      StandardErrorPath = "${logDirectory}/com.maxrn.${name}.error.log";
      EnvironmentVariables.PATH = lib.concatStringsSep ":" [
        "${home}/.local/bin"
        "/etc/profiles/per-user/${config.home.username}/bin"
        "/opt/homebrew/bin"
        "/usr/local/bin"
        "/usr/bin"
        "/bin"
        "/usr/sbin"
        "/sbin"
      ];
    }
    // service;
  }) services;

  home.activation.varlockLogDirectory =
    lib.hm.dag.entryBetween [ "setupLaunchAgents" ] [ "writeBoundary" ]
      ''
        run ${pkgs.coreutils}/bin/install -d -m 700 ${lib.escapeShellArg logDirectory}
      '';
}
