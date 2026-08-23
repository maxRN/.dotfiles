{ config, lib, niks3, pkgs, ... }:
let
  username = config.system.primaryUser;
  userHome = config.users.users.${username}.home;
  nixCacheDir = "${userHome}/.config/nix-cache";
  # niks3-hook send defaults here; ldflags override in the package is broken upstream.
  niks3HookSocketPath = "/run/niks3/upload-to-cache.sock";
in
{
  imports = [ niks3.darwinModules.niks3-auto-upload ];

  services.niks3-auto-upload = {
    enable = true;
    package = niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3-hook;
    serverUrl = "https://niks3-production-9fbd.up.railway.app";
    authTokenFile = "${nixCacheDir}/niks3-token";
    socketPath = niks3HookSocketPath;
  };

  system.activationScripts.extraActivation.text = lib.mkAfter ''
    mkdir -p ${builtins.dirOf niks3HookSocketPath}
  '';

  launchd.daemons.nix-daemon.serviceConfig.EnvironmentVariables = {
    AWS_SHARED_CREDENTIALS_FILE = "${nixCacheDir}/aws-credentials";
    AWS_DEFAULT_REGION = "auto";
  };

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
      "https://nix-community.cachix.org"
      "s3://nix-cache-ew5rx6zbxjs4lpy?endpoint=https://t3.storageapi.dev&region=auto"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "maxrn-niks3:0nrjawYjBmf867QQDtP8UzxgNGVh9bGaGZGVVFg7IRk="
    ];

    # Parallel substitution helps when pulling many small NARs.
    max-substitution-jobs = 16;
    http-connections = 64;
  };
}
