let
  hostname = "ohnezahn";
in
{
  imports = [
    ../../modules/darwin-common.nix
    ./homebrew.nix
    ../../modules/linux-builder.nix
    ../../modules/server.nix
  ];

  networking = {
    hostName = hostname;
    computerName = hostname;
  };

  server.sshAuthorizedKeys = [
    # GitHub key 128219878 (SHA256:Kh5Wwk40…); not ohnezahn's own id_ed25519.
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINmA3oF7BrsfW4eCyrSngTCfzfq8Gx8jfzMwQny+Asip"
  ];

  security.pam.services.sudo_local = {
    # I'm using this as kind of a server now so I want to prompted by password.
    touchIdAuth = false;
  };
}
