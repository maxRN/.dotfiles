{
  description = "NixOS and nix-darwin configuration";

  inputs = {
    # apparently it goes like this from fresh to stale:
    # nixos/nixpkgs/master == nixos/nixpkgs
    # nixos/nixpkgs/nixpkgs-unstable
    # nixos/nixpkgs/nixos-2x.xx
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    pkgs-unstable.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "pkgs-unstable";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "pkgs-unstable";
    };
  };

  outputs =
    {
      self,
      nix-darwin,
      nixpkgs,
      pkgs-unstable,
      home-manager,
      neovim-nightly-overlay,
      sops-nix,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;

      mkOhnezahn =
        { server }:
        nix-darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = {
            pkgs-unstable = import pkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfreePredicate =
                pkg:
                builtins.elem (nixpkgs.lib.getName pkg) [
                  "ffmpeg-full"
                  "claude-code"
                ];
            };
            inherit neovim-nightly-overlay;
          };

          modules = [
            ./hosts/ohnezahn
            sops-nix.darwinModules.sops
            {
              sops.package = sops-nix.packages.aarch64-darwin.sops-install-secrets;
              server.enable = server;
            }
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.verbose = true;
              home-manager.users.maxrn = ./hosts/ohnezahn/home-manager.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        ohnezahn = mkOhnezahn { server = false; };
        ohnezahn-server = mkOhnezahn { server = true; };

        shredder = nix-darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = {
            pkgs-unstable = import pkgs-unstable {
              system = "aarch64-darwin";
              config.allowUnfreePredicate =
                pkg:
                builtins.elem (nixpkgs.lib.getName pkg) [
                  "ffmpeg-full"
                  "claude-code"
                  "1password"
                  "1password-cli"
                ];
            };
            inherit neovim-nightly-overlay;
          };

          modules = [
            ./hosts/shredder

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.verbose = true;
              home-manager.users.maxrn = ./hosts/shredder/home-manager.nix;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      };
      packages = forAllSystems (
        system:
        {
          pi = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/pi { };
          paper-mono = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/paper-mono { };
          paper-mono-slashed-zero = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/paper-mono {
            slashedZero = true;
          };
        }
        // nixpkgs.lib.optionalAttrs (nixpkgs.lib.hasSuffix "darwin" system) {
          secretive = nixpkgs.legacyPackages.${system}.callPackage ./pkgs/secretive { };
        }
      );
      # `nix flake check` doesn't build darwinConfigurations on its own.
      checks.aarch64-darwin = nixpkgs.lib.mapAttrs (_: cfg: cfg.system) self.darwinConfigurations;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
