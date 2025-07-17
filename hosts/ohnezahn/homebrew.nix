{
  homebrew = {
    enable = true;
    casks = [
      "discord"
      "spotify"
      "maestral"
      "rectangle" # Installing via homebrew instead of home-manager, because apps don't show up in spotlight otherwise
      # tbf they do show up in Raycast, but I'm trying to go back from that
      # see issue: https://github.com/nix-darwin/nix-darwin/issues/1079
      "musicbrainz-picard"
    ];
    masApps = {
      Tailscale = 1475387142;
      AdBlocker = 1365531024;
    };
  };
}
