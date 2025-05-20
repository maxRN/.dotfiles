{ config, ... }:
let
  sshkey = key: {
    name = key;
    value = {
      owner = config.users.users.maxrn.name;
      path = config.users.users.maxrn.home + "/.ssh/" + key;
      sopsFile = ../secrets/ssh.yaml;
    };
  };
  pssh = keys: builtins.listToAttrs (map sshkey keys);
in
{
  sops = {
    # This will add secrets.yml to the nix store
    # You can avoid this by adding a string to the full path instead, i.e.
    # sops.defaultSopsFile = "/root/.sops/secrets/example.yaml";
    defaultSopsFile = ../secrets/secrets.yaml;

    age = {
      # This will automatically import SSH keys as age keys
      sshKeyPaths = [ (config.users.users.maxrn.home + "/.ssh/main") ];
      generateKey = true;
      # This is using an age key that is expected to already be in the filesystem
      keyFile = config.users.users.maxrn.home + ".config/sops/age/keys.txt";
    };

    # This is the actual specification of the secrets.
    secrets = pssh [
      "scone_masterthesis"
      "github"
      "codeberg"
      "parents_pi2w"
      "raspi"
      "se-gitlab"
      "mn_gitlab"
    ];
  };
}
