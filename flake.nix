{
  description = "NixOS and nix-darwin configuration";

  inputs = {
    # apparently it goes like this from fresh to stale:
    # nixos/nixpkgs/master == nixos/nixpkgs
    # nixos/nixpkgs/nixpkgs-unstable
    # nixos/nixpkgs/nixos-2x.xx
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-24.11-darwin";
    pkgs-unstable.url = "github:nixos/nixpkgs/master";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.91.1-2.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay = {
      url = "github:nix-community/neovim-nightly-overlay";
      inputs.nixpkgs.follows = "pkgs-unstable";
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
      ...
    }:
    let
      forAllSystems = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed;
    in
    {
      darwinConfigurations = {
        spren = nix-darwin.lib.darwinSystem rec {
          system = "aarch64-darwin";
          specialArgs = {
            pkgs-unstable = import pkgs-unstable { system = "aarch64-darwin"; };
            inherit neovim-nightly-overlay;
          };

          modules = [
            ./hosts/work/configuration.nix
            lix-module.nixosModules.default

            ./darwin/system.nix
            ./modules/fish-fix.nix

            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.verbose = true;
              home-manager.users.maxrn = ./home;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ];
        };
      };
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
