{
  programs.tmux = {
    extraConfig = ''
      bind-key -r N run-shell "tmux-sessionizer ~/uni/nomon"
      bind-key -r 8 run-shell "tmux-sessionizer ~/uni/k8s-scone"
    '';
  };

}
