{
  description = "NixOS and nix-darwin configuration";

  inputs = {
    # apparently it goes like this from fresh to stale:
    # nixos/nixpkgs/master == nixos/nixpkgs
    # nixos/nixpkgs/nixpkgs-unstable
    # nixos/nixpkgs/nixos-2x.xx
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    pkgs-unstable.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.93.3-1.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "pkgs-unstable";
    };
    codelldb = {
      url = "github:mrcjkb/rustaceanvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      lix-module,
      nix-darwin,
      nixpkgs,
      pkgs-unstable,
      home-manager,
      neovim-nightly-overlay,
      codelldb,
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      darwinConfigurations = {
        ohnezahn = nix-darwin.lib.darwinSystem rec {
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
            inherit neovim-nightly-overlay codelldb;
          };

          modules = [
            ./hosts/ohnezahn
            lix-module.nixosModules.default

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
                ];
            };
            inherit neovim-nightly-overlay codelldb;
          };

          modules = [
            ./hosts/shredder
            lix-module.nixosModules.default

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
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
