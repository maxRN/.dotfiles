{
  programs.ssh = {
    enable = true;
    extraConfig = ''
      Include ~/.config/colima/ssh_config

      Host pi
          HostName 192.168.1.4
          User pi
          IdentityFile ~/.ssh/raspi
          SetEnv TERM=xterm-256color
      Host jump-serve
          HostName login.zih.tu-dresden.de 
          User s4389254
          IdentityFile ~/.ssh/scone_masterarbeit_cluster
          SetEnv TERM=xterm-256color
      Host sgx4
          Hostname 141.76.44.84
          IdentityFile ~/.ssh/scone_masterarbeit_cluster
          User max.grosse
          ProxyJump jump-serve
          SetEnv TERM=xterm-256color
      Host sgx25
          Hostname 141.76.44.112
          IdentityFile ~/.ssh/scone_masterarbeit_cluster
          User max.grosse
          ProxyJump jump-serve
          SetEnv TERM=xterm-256color
      Host barney
          Hostname 141.76.44.113
          User ubuntu
          ProxyJump jump-serve
          IdentityFile ~/.ssh/scone_masterarbeit_cluster
          SetEnv TERM=xterm-256color
      Host zero2
          Hostname zero2
          IdentityFile ~/.ssh/parents_pi2w
          User eltern
          SetEnv TERM=xterm-256color
    '';
  };
}
