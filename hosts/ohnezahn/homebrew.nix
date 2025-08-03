{
  imports = [ ../../home/homebrew.nix ];
  homebrew = {
    enable = true;
    casks = [
      "discord"
      "musicbrainz-picard"
      "orbstack"
    ];
    masApps = {
      Tailscale = 1475387142;
    };
  };
}
