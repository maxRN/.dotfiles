{
  programs.ssh = {
    enable = true;
    settings."*" = {
      ForwardAgent = false;
      AddKeysToAgent = "no";
      Compression = false;
      ServerAliveInterval = 0;
      ServerAliveCountMax = 3;
      HashKnownHosts = false;
      UserKnownHostsFile = "~/.ssh/known_hosts";
      ControlMaster = "no";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "no";
    };
    enableDefaultConfig = false;
    extraConfig = ''
      Host *
          IdentityFile ~/.ssh/id_ed25519
          SetEnv TERM=xterm-256color
      Host beholder
          HostName 10.10.0.4
          User root
      Host jump-serve
          HostName login.zih.tu-dresden.de 
          User s4389254
      Host barney
          Hostname 141.76.44.113
          User ubuntu
          ProxyJump jump-serve
      Host zero2
          Hostname zero2
          IdentityFile ~/.ssh/parents_pi2w
          User eltern
      Host kaladin
          User root
      Host beast
          User mgrosse
          HostName 141.76.44.200
          ProxyJump jump-serve
      Host bigboy
          User max
          HostName 141.76.44.130
          ProxyJump beast
    '';
  };
}
