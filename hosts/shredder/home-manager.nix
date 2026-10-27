{
  pkgs,
  ...
}:
{
  imports = [
    ../../home/default.nix
    ../../home/darwin.nix
    ./varlock.nix
  ];

  home.sessionVariables = {
    ANDROID_HOME = "$HOME/Library/Android/sdk";
  };

  home.sessionPath = [
    "$ANDROID_HOME/platform-tools"
  ];

  # The 1Password app lives in /Applications and updates itself; op comes from
  # programs._1password in ./default.nix.
  home.packages = with pkgs; [
    awscli2
    jdk17
    mysql84
    postgresql
    grafana-loki
  ];
}
