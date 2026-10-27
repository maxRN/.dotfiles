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

      # One nix-darwin system with home-manager for maxrn. `unstableUnfree` only
      # applies to pkgs-unstable; the stable package set keeps its own policy.
      mkDarwin =
        {
          hostModule,
          homeModule,
          extraModules ? [ ],
          unstableUnfree ? [ ],
        }:
        let
          system = "aarch64-darwin";
        in
        nix-darwin.lib.darwinSystem rec {
          specialArgs = {
            pkgs-unstable = import pkgs-unstable {
              inherit system;
              config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) unstableUnfree;
            };
            inherit neovim-nightly-overlay;
          };

          modules = [
            { nixpkgs.hostPlatform = system; }
            hostModule
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.verbose = true;
              home-manager.users.maxrn = homeModule;
              home-manager.extraSpecialArgs = specialArgs;
            }
          ]
          ++ extraModules;
        };

      mkOhnezahn =
        { server }:
        mkDarwin {
          hostModule = ./hosts/ohnezahn;
          homeModule = ./hosts/ohnezahn/home-manager.nix;
          extraModules = [
            sops-nix.darwinModules.sops
            {
              sops.package = sops-nix.packages.aarch64-darwin.sops-install-secrets;
              server.enable = server;
            }
          ];
          unstableUnfree = [
            "ffmpeg-full"
            "claude-code"
          ];
        };
    in
    {
      darwinConfigurations = {
        ohnezahn = mkOhnezahn { server = false; };
        ohnezahn-server = mkOhnezahn { server = true; };

        shredder = mkDarwin {
          hostModule = ./hosts/shredder;
          homeModule = ./hosts/shredder/home-manager.nix;
          unstableUnfree = [
            "ffmpeg-full"
            "claude-code"
            "1password"
            "1password-cli"
          ];
        };
      };
      packages = forAllSystems (system: import ./pkgs { pkgs = nixpkgs.legacyPackages.${system}; });
      # `nix flake check` doesn't build darwinConfigurations on its own.
      checks.aarch64-darwin = nixpkgs.lib.mapAttrs (_: cfg: cfg.system) self.darwinConfigurations;
      formatter = forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}
