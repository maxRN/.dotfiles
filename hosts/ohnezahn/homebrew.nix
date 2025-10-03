{
  imports = [ ../../home/homebrew.nix ];
  homebrew = {
    enable = true;
    casks = [
      "musicbrainz-picard"
      "orbstack"
    ];
    masApps = {
    };
  };
}
