{ pkgs, config, ... }:
{
  programs.tmux = {
    enable = true;
    baseIndex = 1;
    clock24 = true;
    disableConfirmationPrompt = true;
    historyLimit = 10000;
    prefix = "C-a";
    shell = "${pkgs.fish}/bin/fish";
    shortcut = "a";
    mouse = true;
    keyMode = "vi";
    escapeTime = 10;
    plugins = with pkgs; [
      {
        plugin = tmuxPlugins.catppuccin;
        # extraConfig = "set -g @catppuccin_flavour 'latte'";
        extraConfig = "set -g @catppuccin_flavour 'mocha'";
      }
    ];

    extraConfig = ''
      set-option -ga terminal-overrides ",xterm-256color:Tc"
      set-option -g default-terminal "tmux-256color"

      # bind == bind-key
      bind-key -r f run-shell "tmux-sessionizer"
      bind-key -r I display-popup -E 'ask-gpt' 
      bind-key c new-window -c "#{pane_current_path}"

	  bind-key -r r source-file ~/.config/tmux/tmux.conf \; display-message "tmux config reloaded!"

      # setw -g mode-keys vi
      bind-key -T copy-mode-vi v send -X begin-selection
      bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "pbcopy"
      bind-key P paste-buffer

      # vim-like pane switching
      bind-key ^ last-window
      bind-key k select-pane -U
      bind-key j select-pane -D
      bind-key h select-pane -L
      bind-key l select-pane -R

      # window_activity is last time of activity in current window in unix time
      # formatting is done with strftime, see man strftime for more information
      # set -g status-right "${config.home.username} #{t/f/%%H#:%%M %%Y-%%-m-%%d %%A:window_activity} "

      # So session name doesn't get cut off
      set -g status-left-length 30 # could be any number
    '';
  };
}
