{
  pkgs,
  ...
}:
{
  nix.package = pkgs.lixPackageSets.stable.lix;

  nix.optimise.automatic = true;

  # Keep recent store paths so automatic GC does not force re-downloads.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # System-wide binary caches (applies to every nix / darwin-rebuild / nix develop).
  # cache.nixos.org is already the default; these append via extra-*.
  nix.settings = {
    extra-substituters = [
      "https://pi.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "pi.cachix.org-1:lGeoGJaZ5ZDabuRzkcD5EBTNnDM4HJ1vqeOxlWk1Flk="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];

    # Parallel substitution helps when pulling many small NARs.
    max-substitution-jobs = 16;
    http-connections = 64;
  };
}
