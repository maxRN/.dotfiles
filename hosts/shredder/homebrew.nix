{
  imports = [ ../../home/homebrew.nix ];
  homebrew = {
    enable = true;
    casks = [
      "1password"
      "yaak"
    ];
  };
}
