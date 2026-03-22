{
  homebrew = {
    enable = true;
    casks = [
      "spotify"
      "discord"
      # "maestral"
      # tbf they do show up in Raycast, but I'm trying to go back from that
      # see issue: https://github.com/nix-darwin/nix-darwin/issues/1079
      "ghostty"
      "aldente"
      "obsidian"
      "routine"
      "google-chrome"
      "dropbox"
    ];
    masApps = {
      "uBlock Origin Lite" = 6745342698;
    };
  };
}
