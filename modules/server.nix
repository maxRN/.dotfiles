# Unattended-server profile for ohnezahn (MacBook Air M3, Mac15,12).
#
# Imported by both `#ohnezahn` (server.enable = false) and `#ohnezahn-server`
# (server.enable = true). Everything sticky (pmset, Remote Login,
# DevToolsSecurity, auto-install of macOS updates) is set explicitly in BOTH
# branches, so switching profiles reverts it. Screen Sharing is deliberately not
# managed: started via launchctl it listens but refuses connections ("Screen
# Sharing is not permitted") until toggled in System Settings. See
# docs/ohnezahn-server.md.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.server;
  user = config.system.primaryUser;
  home = config.users.users.${user}.home;
  profileName = if cfg.enable then "server" else "laptop";

  # Only keys `pmset -g cap` lists on this machine. `autorestart` is missing
  # from cap on Mac15,12, so restart-after-power-loss can't be set via pmset.
  power =
    if cfg.enable then
      {
        battery = {
          sleep = 0;
          displaysleep = 2;
          disksleep = 0;
          standby = 0;
          powernap = 0;
          tcpkeepalive = 1;
          womp = 1;
          ttyskeepawake = 1;
          hibernatemode = 3;
          lessbright = 1;
          # Stretch runtime (and cut heat) if wall power drops.
          lowpowermode = 1;
        };
        ac = {
          sleep = 0;
          displaysleep = 2;
          disksleep = 0;
          standby = 0;
          powernap = 0;
          tcpkeepalive = 1;
          womp = 1;
          ttyskeepawake = 1;
          hibernatemode = 3;
          lowpowermode = 0;
        };
        # Undocumented in pmset(8); shown as `SleepDisabled` by `pmset -g`.
        # The only knob that keeps an Apple silicon laptop awake with the lid closed.
        disablesleep = 1;
      }
    else
      {
        # Snapshot of `pmset -g custom` taken 2026-10-25, before server mode existed.
        battery = {
          sleep = 1;
          displaysleep = 5;
          disksleep = 10;
          standby = 1;
          powernap = 1;
          tcpkeepalive = 1;
          womp = 0;
          ttyskeepawake = 1;
          hibernatemode = 3;
          lessbright = 1;
          lowpowermode = 0;
        };
        ac = {
          sleep = 0;
          displaysleep = 10;
          disksleep = 10;
          standby = 1;
          powernap = 1;
          tcpkeepalive = 1;
          womp = 1;
          ttyskeepawake = 1;
          hibernatemode = 3;
          lowpowermode = 0;
        };
        disablesleep = 0;
      };

  pmsetArgs = attrs: lib.concatStringsSep " " (lib.mapAttrsToList (k: v: "${k} ${toString v}") attrs);

  # "<section> <key> <value>" lines, compared against `pmset -g custom` by ohnezahn-check.
  powerExpected = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (k: v: "Battery ${k} ${toString v}") power.battery
    ++ lib.mapAttrsToList (k: v: "AC ${k} ${toString v}") power.ac
    ++ [ "System SleepDisabled ${toString power.disablesleep}" ]
  );

  tailscale = "/opt/homebrew/bin/tailscale";
  tailscaledLabel = "homebrew.mxcl.tailscale";
  rexSocket = "${home}/Library/Application Support/rex/server.sock";

  # Runs a command in the logged-in user's GUI (Aqua) launchd domain, e.g. from SSH.
  gui = pkgs.writeShellApplication {
    name = "gui";
    text = ''
      uid=$(id -u)
      if ! launchctl print "gui/$uid" >/dev/null 2>&1; then
        echo "gui: no GUI session for uid $uid; log in via Screen Sharing first" >&2
        exit 1
      fi
      exec sudo launchctl asuser "$uid" sudo -u "$USER" -- "$@"
    '';
  };

  check = pkgs.writeShellApplication {
    name = "ohnezahn-check";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./server/ohnezahn-check.sh;
  };

  update = pkgs.writeShellApplication {
    name = "ohnezahn-update";
    runtimeInputs = [
      pkgs.nvd
      pkgs.git
    ];
    text = builtins.readFile ./server/ohnezahn-update.sh;
  };
in
{
  options.server = {
    enable = lib.mkEnableOption "unattended server mode (lid closed, remote access, KeepAlive agents)";

    sshAuthorizedKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "Public keys accepted by the keys-only sshd fallback.";
    };
  };

  config = lib.mkMerge [
    # ---------------------------------------------------------------- both
    {
      environment.etc."ohnezahn/profile".text = profileName + "\n";
      environment.etc."ohnezahn/power.expected".text = powerExpected + "\n";
      environment.systemPackages = [
        check
        update
        gui
      ];

      system.activationScripts.power.text = lib.mkAfter ''
        echo "applying ${profileName} pmset profile..." >&2
        pmset -b ${pmsetArgs power.battery}
        pmset -c ${pmsetArgs power.ac}
        pmset -a disablesleep ${toString power.disablesleep}
      '';
      power.restartAfterFreeze = true;

      # Homebrew's open-source tailscaled (system daemon, KeepAlive, runs before
      # login) in both profiles: nixpkgs' tailscale (1.90.9 / 1.98.8) is older than
      # the 1.102.3 that owns /Library/Tailscale/tailscaled.state, and restarting
      # tailscaled during a switch would kill the Tailscale SSH session doing it.
      homebrew.brews = [ "tailscale" ];

      # Keys-only when sshd runs. Note: the macOS 26+ FileVault pre-boot unlock
      # over SSH can't read this file (it lives on the locked data volume) and
      # always uses password auth; see apple_ssh_and_filevault(7).
      services.openssh.extraConfig = ''
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        PermitRootLogin no
        AuthenticationMethods publickey
        AllowUsers ${user}
      '';
      users.users.${user}.openssh.authorizedKeys.keys = cfg.sshAuthorizedKeys;

      # Adopted from the hand-written ~/Library/LaunchAgents plist (same label),
      # kept in both profiles because it ran in laptop mode before, too.
      sops = {
        defaultSopsFile = ../secrets/ohnezahn.yaml;
        age.keyFile = "${home}/.config/sops/age/keys.txt";
        # Defaults also try /etc/ssh/ssh_host_*_key, which macOS only creates on
        # first sshd use ("Cannot read ssh key" noise) and pull in gnupg.
        age.sshKeyPaths = [ ];
        gnupg.sshKeyPaths = [ ];
        secrets.blinks_api_key = {
          owner = user;
          # sync_blinks.py falls back to this path when BLINKS_API_KEY is unset.
          path = "${home}/.config/blinks-sync/api_key";
        };
      };
      launchd.user.agents.linkding-sync.serviceConfig = {
        Label = "dev.maxrn.linkding-sync";
        ProgramArguments = [
          "/etc/profiles/per-user/${user}/bin/uv"
          "run"
          "--script"
          "${home}/code/linkding-sync/sync_blinks.py"
        ];
        EnvironmentVariables = {
          BLINKS_URL = "https://blinks-production-2f5e.up.railway.app";
          HOME = home;
          PATH = "/etc/profiles/per-user/${user}/bin:/usr/bin:/bin";
        };
        StartInterval = 3600;
        RunAtLoad = false;
        StandardOutPath = "${home}/Library/Logs/linkding-sync.log";
        StandardErrorPath = "${home}/Library/Logs/linkding-sync.log";
      };
    }

    # -------------------------------------------------------------- laptop
    (lib.mkIf (!cfg.enable) {
      services.openssh.enable = false;
      system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = true;

      system.activationScripts.postActivation.text = ''
        echo "server mode off: disabling DevToolsSecurity..." >&2
        DevToolsSecurity -disable >/dev/null 2>&1 || true
      '';
    })

    # -------------------------------------------------------------- server
    (lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = cfg.sshAuthorizedKeys != [ ];
          message = "server.sshAuthorizedKeys is empty: the keys-only sshd fallback would admit nobody.";
        }
      ];

      # Remote Login: fallback when tailscaled is broken (reachable on the LAN or
      # via a LAN jump host), and needed for the FileVault pre-boot SSH unlock.
      services.openssh.enable = true;

      # Reboots only when planned (ohnezahn-update macos / reboot).
      system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;

      system.activationScripts.postActivation.text = ''
        echo "server mode on: DevToolsSecurity, boot-on-power, Tailscale SSH..." >&2

        # lldb / xcodebuild test over SSH can't answer the debugger auth dialog.
        DevToolsSecurity -enable >/dev/null 2>&1 || true

        # Apple silicon laptops boot on power connect unless BootPreference says otherwise
        # (support.apple.com/120622). That is the only "restart after power loss" here.
        nvram -d BootPreference 2>/dev/null || true

        if [ -x ${tailscale} ] && ${tailscale} status >/dev/null 2>&1; then
          ${tailscale} set --ssh=true || echo "warning: tailscale set --ssh failed" >&2
        else
          echo "warning: tailscaled not running; Tailscale SSH not (re)asserted" >&2
        fi
      '';

      # Self-heal Wi-Fi and tailscaled without anyone at the machine.
      launchd.daemons.server-watchdog = {
        path = [ pkgs.jq ];
        script = ''
          set -u
          state=/var/db/server-watchdog
          mkdir -p "$state"
          now=$(date +%s)
          log() { echo "$(date '+%F %T') $*"; }
          bump() { n=$(( $(cat "$state/$1" 2>/dev/null || echo 0) + 1 )); echo "$n" > "$state/$1"; echo "$n"; }

          wifi=$(/usr/sbin/networksetup -listallhardwareports | awk '/Hardware Port: Wi-Fi/{getline; print $2}')
          gw=$(/sbin/route -n get default 2>/dev/null | awk '/gateway:/{print $2}')
          if [ -n "$gw" ] && /sbin/ping -q -c 3 -t 5 "$gw" >/dev/null 2>&1; then
            echo 0 > "$state/net-fail"
          elif [ "$(bump net-fail)" -ge 2 ] && [ -n "$wifi" ]; then
            last=$(cat "$state/wifi-cycled" 2>/dev/null || echo 0)
            if [ $(( now - last )) -ge 1800 ]; then
              log "gateway unreachable for 2 checks; power-cycling Wi-Fi ($wifi)"
              /usr/sbin/networksetup -setairportpower "$wifi" off
              sleep 5
              /usr/sbin/networksetup -setairportpower "$wifi" on
              echo "$now" > "$state/wifi-cycled"
            fi
          fi

          backend=$(${tailscale} status --json 2>/dev/null | jq -r '.BackendState // "unknown"')
          if [ "$backend" = "Running" ]; then
            echo 0 > "$state/ts-fail"
          elif [ "$(bump ts-fail)" -ge 2 ]; then
            log "tailscale BackendState=$backend for 2 checks; kickstarting ${tailscaledLabel}"
            /bin/launchctl kickstart -k system/${tailscaledLabel}
            echo 0 > "$state/ts-fail"
          fi
        '';
        serviceConfig = {
          StartInterval = 300;
          RunAtLoad = true;
          StandardOutPath = "/var/log/server-watchdog.log";
          StandardErrorPath = "/var/log/server-watchdog.log";
        };
      };

      # Rex server outside Rex.app, so sessions survive the app being closed and
      # come back after login. Same bundle (com.superlogical.rex.server) as the
      # app-spawned server, so its TCC grants apply. If Rex.app already started
      # one, this exits 0 and launchd re-checks after ThrottleInterval.
      launchd.user.agents.rex-server = {
        script = ''
          # home-manager's resolver (home/rex.nix); Rex moves its CLI between releases.
          rex=${lib.escapeShellArg "${home}/.local/bin/rex"}
          if "$rex" --autostart=false --timeout 5s ls >/dev/null 2>&1; then
            exit 0
          fi
          exec "$rex" server run \
            --listen ${lib.escapeShellArg "unix://${lib.replaceStrings [ " " ] [ "%20" ] rexSocket}"} \
            --websocket-origin-pattern https://rex.superlogical.com \
            --log-format text
        '';
        serviceConfig = {
          KeepAlive = true;
          ThrottleInterval = 60;
          LimitLoadToSessionType = "Aqua";
          StandardOutPath = "${home}/Library/Logs/rex-server-agent.log";
          StandardErrorPath = "${home}/Library/Logs/rex-server-agent.log";
        };
      };

      # Grok Bot (Anysphere, com.anysphere.sand) is an Electron GUI app; `open -W`
      # waits for it (also when already running), so launchd relaunches it after
      # a crash or a ShipIt self-update quits it.
      launchd.user.agents.grok-bot.serviceConfig = {
        ProgramArguments = [
          "/usr/bin/open"
          "-W"
          "-g"
          "-a"
          "/Applications/Grok Bot.app"
        ];
        KeepAlive = true;
        ThrottleInterval = 60;
        LimitLoadToSessionType = "Aqua";
        StandardOutPath = "${home}/Library/Logs/grok-bot-agent.log";
        StandardErrorPath = "${home}/Library/Logs/grok-bot-agent.log";
      };
    })
  ];
}
