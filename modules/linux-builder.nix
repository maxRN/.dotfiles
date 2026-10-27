# aarch64-linux builder VM, so ohnezahn can build NixOS systems (e.g. radiants' `beholder`)
# natively instead of on the target. Builds that need aarch64-linux are dispatched
# to it automatically via nix.buildMachines.
#
# Start with the defaults: customising `config` (cores, memory) means the builder
# image itself has to be built, which needs a working builder first.
{
  nix.linux-builder.enable = true;
}
