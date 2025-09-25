{
  pkgs,
  pkgs-unstable,
  ...
}:
{
  imports = [
    ../../home/default.nix
    ../../home/darwin.nix
  ];

  home.sessionVariables = {
    ANDROID_HOME = "$HOME/Library/Android/sdk";
  };

  home.sessionPath = [
    "$ANDROID_HOME/platform-tools"
  ];

  home.packages =
    let
      unstable = with pkgs-unstable; [
        _1password-gui
        _1password-cli
      ];

      stable = with pkgs; [
        awscli2
        jdk17
      ];
    in
    stable ++ unstable;
}
