{
  homebrew = {
    enable = true;
    casks = [
      "spotify"
      # "maestral"
      "rectangle" # Installing via homebrew instead of home-manager, because apps don't show up in spotlight otherwise
      # tbf they do show up in Raycast, but I'm trying to go back from that
      # see issue: https://github.com/nix-darwin/nix-darwin/issues/1079
      "raycast"
      "ghostty"
      "docker-desktop"
      "aldente"
    ];
    masApps = {
      AdBlocker = 1365531024;
    };
  };
}
