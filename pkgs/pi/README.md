# Pi

This package pins the official Pi source release and uses its Nix build recipe,
including the pinned npm dependencies and model catalog.

Home Manager installs it directly through `pkgs.callPackage`. Credentials,
sessions, extensions, and settings in `~/.pi` remain unmanaged.

Build or run from the dotfiles root:

```sh
nix build .#pi
nix run .#pi -- --version
```

## Updating

1. Change `version` in `default.nix` and update the source `hash`.
2. Build and verify the version:

   ```sh
   nix build .#pi
   nix run .#pi -- --version
   ```

No Pi flake input or separate lockfile is needed.
