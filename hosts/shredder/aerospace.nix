{
  services.aerospace.enable = true;
  services.aerospace.settings = {
    accordion-padding = 30;
    after-login-command = [ ];
    after-startup-command = [
      "exec-and-forget borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0"
    ];
    default-root-container-layout = "tiles";
    default-root-container-orientation = "auto";
    enable-normalization-flatten-containers = true;
    enable-normalization-opposite-orientation-for-nested-containers = true;
    exec-on-workspace-change = [ ];
    gaps.inner = {
      horizontal = 16;
      vertical = 16;
    };
    gaps.outer = {
      bottom = 16;
      left = 16;
      right = 16;
      top = 16;
    };
    key-mapping = {
      preset = "qwerty";
    };
    mode.main.binding = {
      alt-0 = "workspace 10";
      alt-1 = "workspace 1";
      alt-2 = "workspace 2";
      alt-3 = "workspace 3";
      alt-4 = "workspace 4";
      alt-5 = "workspace 5";
      alt-6 = "workspace 6";
      alt-7 = "workspace 7";
      alt-8 = "workspace 8";
      alt-9 = "workspace 9";
      alt-comma = "layout accordion horizontal vertical";
      alt-enter = ''
        exec-and-forget osascript -e 'tell application "Ghostty"
            activate
            tell application "System Events"
                keystroke "n" using command down
            end tell
        end tell'
      '';
      alt-h = "focus left";
      alt-j = "focus down";
      alt-k = "focus up";
      alt-l = "focus right";
      alt-shift-0 = [
        "move-node-to-workspace 10"
        "workspace 10"
      ];
      alt-shift-1 = [
        "move-node-to-workspace 1"
        "workspace 1"
      ];
      alt-shift-2 = [
        "move-node-to-workspace 2"
        "workspace 2"
      ];
      alt-shift-3 = [
        "move-node-to-workspace 3"
        "workspace 3"
      ];
      alt-shift-4 = [
        "move-node-to-workspace 4"
        "workspace 4"
      ];
      alt-shift-5 = [
        "move-node-to-workspace 5"
        "workspace 5"
      ];
      alt-shift-6 = [
        "move-node-to-workspace 6"
        "workspace 6"
      ];
      alt-shift-7 = [
        "move-node-to-workspace 7"
        "workspace 7"
      ];
      alt-shift-8 = [
        "move-node-to-workspace 8"
        "workspace 8"
      ];
      alt-shift-9 = [
        "move-node-to-workspace 9"
        "workspace 9"
      ];
      alt-shift-equal = "resize smart +50";
      alt-shift-h = "move left";
      alt-shift-j = "move down";
      alt-shift-k = "move up";
      alt-shift-l = "move right";
      alt-shift-minus = "resize smart -50";
      alt-shift-semicolon = "mode service";
      alt-shift-tab = "move-workspace-to-monitor --wrap-around next";
      alt-slash = "layout tiles horizontal vertical";
      alt-tab = "workspace-back-and-forth";
    };
    mode.service.binding = {
      b = [
        "balance-sizes"
        "mode main"
      ];
      backspace = [
        "close-all-windows-but-current"
        "mode main"
      ];
      esc = [
        "reload-config"
        "mode main"
      ];
      f = [
        "layout floating tiling"
        "mode main"
      ];
      r = [
        "flatten-workspace-tree"
        "mode main"
      ];
      x = [
        "fullscreen"
        "mode main"
      ];
    };
    on-focus-changed = [ ];
    on-focused-monitor-changed = [ "move-mouse monitor-lazy-center" ];
    on-window-detected = [
      {
        "if" = {
          app-name-regex-substring = "Safari";
        };
        run = [
          "move-node-to-workspace 1"
        ];
      }
      {
        "if" = {
          app-id = "com.mitchellh.ghostty";
        };
        run = [
          "move-node-to-workspace 2"
        ];
      }
      {
        "if" = {
          app-id = "md.obsidian";
        };
        run = [
          "move-node-to-workspace 3"
        ];
      }
      {
        "if" = {
          app-name-regex-substring = "Slack";
        };
        run = [
          "move-node-to-workspace 6"
        ];
      }
      {
        "if" = {
          app-name-regex-substring = "qemu-system";
        };
        run = [
          "layout floating"
          "move-node-to-workspace 4"
        ];
      }
    ];
    # cause it's managed by home manager?? Or something idk...
    start-at-login = false;
    workspace-to-monitor-force-assignment = { };
  };
}
