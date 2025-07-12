{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Host *
          IdentityFile ~/.ssh/id_ed25519
          SetEnv TERM=xterm-256color
      Host pi
          HostName 192.168.1.4
          User pi
          IdentityFile ~/.ssh/raspi
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
      Host windrunner
          Hostname 128.140.121.222
          IdentityFile ~/.ssh/main
          User root
    '';
  };
}
