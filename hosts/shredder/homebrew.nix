{
  imports = [ ../../home/homebrew.nix ];
  homebrew = {
    enable = true;
    casks = [
      "docker-desktop"
      "yaak"
      "slack"
    ];
  };
}
