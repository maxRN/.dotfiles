{
  config,
  lib,
  niks3,
  pkgs,
  ...
}:
let
  username = config.system.primaryUser;
  userHome = config.users.users.${username}.home;
  nixCacheDir = "${userHome}/.config/nix-cache";
  # Keep the socket in persistent state: /run is cleared during macOS boots.
  niks3HookSocketPath = "/var/lib/niks3-hook/upload-to-cache.sock";
  niks3Hook = lib.getExe' niks3.packages.${pkgs.stdenv.hostPlatform.system}.niks3-hook "niks3-hook";
  # Pass the socket explicitly because the package's ldflags override is broken upstream.
  niks3PostBuildHook = pkgs.writeShellScript "niks3-post-build-hook" ''
    exec ${niks3Hook} send --socket ${lib.escapeShellArg niks3HookSocketPath} "$@"
  '';
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

  # Override the upstream wrapper so the sender and daemon always use the same socket.
  nix.settings.post-build-hook = lib.mkForce niks3PostBuildHook;

  system.activationScripts.extraActivation.text = lib.mkAfter ''
    mkdir -p ${lib.escapeShellArg (builtins.dirOf niks3HookSocketPath)}
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
