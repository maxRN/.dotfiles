# ohnezahn as an unattended server

`ohnezahn` (MacBook Air 13" M3, `Mac15,12`, fanless, firmware 20457.1.29, macOS 27.0.1) runs in two profiles from the same flake:

```sh
sudo darwin-rebuild switch --flake ~/code/.dotfiles#ohnezahn-server   # server
sudo darwin-rebuild switch --flake ~/code/.dotfiles#ohnezahn          # laptop
ohnezahn-update nix --to server|laptop                                # same, with nvd diff + check
ohnezahn-check                                                         # live state vs active profile
```

A bare `darwin-rebuild switch --flake .` resolves to `#ohnezahn` by hostname, which **silently leaves server mode**. Always name the attribute, or use `ohnezahn-update`, which reads `/etc/ohnezahn/profile`.

Code: `modules/server.nix`, `modules/server/ohnezahn-{check,update}.sh`, `secrets/ohnezahn.yaml`, `.sops.yaml`.

---

## 1. Audit (2026-10-25)

### Machine state, from primary sources

| Source | Finding |
|---|---|
| `pmset -g custom` | Battery: `sleep 1`, `displaysleep 5`, `powernap 1`, `standby 1`, `womp 0`. AC: `sleep 0`, `displaysleep 10`, `womp 1`. `SleepDisabled 0`. The `#ohnezahn` profile pins exactly these values. |
| `pmset -g cap` | No `autorestart` or `autorestartatconnect`: restart-after-power-loss can't be set via pmset on this machine. |
| `pmset -g log` (7 days) | 98 sleeps, 2 of them `Clamshell Sleep` (2026-10-24). No thermal events. While on AC, charge held at 80. |
| `pmset -g assertions` | Cursor holds `NoIdleSleepAssertion`. Assertions don't stop clamshell sleep. |
| `fdesetup status` / `supportsauthrestart` | FileVault on; authrestart supported. No auto-login (`autoLoginUser` unset, no `/etc/kcpassword`). Secure token on for `maxrn`. |
| `ioreg -rn AppleSmartBattery` | 113 cycles, FullChargeCapacity 4252 of DesignCapacity 4563 mAh (93%). |
| `defaults read com.apphousekitchen.aldente-pro` | AlDente 1.34.1 runs with `useTahoeNativeLimit = 1`, `chargeVal = 80`, i.e. it delegates to the macOS native limit. |
| `launchctl print gui/501` | Hand-written agent: `dev.maxrn.linkding-sync`. Rex server and Grok Bot have no agents; Rex.app spawns its server. |
| `softwareupdate --list` | Nothing pending. `AutomaticallyInstallMacOSUpdates = 1`. |
| `brew outdated --greedy` | 44 formulae, 15 casks (incl. `tailscale` 1.102.3 → 1.104.2, `dropbox`, `aldente`). `mas outdated`: Xcode 27.0 → 27.1. |
| `tailscale version` / `debug prefs` / `status --json` | Homebrew **open-source tailscaled 1.102.3** as system daemon `homebrew.mxcl.tailscale` (KeepAlive). `RunSSH: true`. Tag `tag:build-mac`, but **`KeyExpiry 2027-02-18`**. *Untagged and re-authenticated as maxRN@github since; see §7.* |
| `systemextensionsctl list` / `scutil --nc list` | A stale **Standalone Tailscale network extension** (1.102.2) is activated, plus two disconnected VPN profiles ("Tailscale", "Tailscale 2"). No Tailscale.app is installed. |
| Remote Login / Screen Sharing | Both off (ports 22 and 5900 closed). sshd config files from nix-darwin already exist. |
| Wi-Fi | WPA2 Personal, 5 GHz; LAN IP 192.168.1.122. USB Ethernet adapters present (en3, en4). |
| `system_profiler` firmware | 20457.1.29. Per the batt README, this firmware gates SMC charge keys behind a private entitlement. |
| TCC | **Not readable.** Both TCC.db files refuse this session (`authorization denied`; terminal lacks Full Disk Access). The unified log kept 4 TCC lines in 7 days. See §4 for the inventory and how to dump the real grants. |
| Repo | **`key.raw.txt` is the git-crypt master key** (base64 of `\0GITCRYPTKEY…`) committed to the **public** repo `maxRN/.dotfiles`. Anything ever git-crypt-encrypted in history (e.g. commit `d0aa8ae add Berkeley Mono`) is public. |
| `~/.config/sops/age/keys.txt` | Exists, mode **0644**. |
| linkding-sync log | Every clipping is skipped with `[Errno 11] Resource deadlock avoided`: iCloud files are evicted (dataless) and a background job can't download them. |

### nix-darwin source at the pinned rev (`ebec37a`, nix-darwin-25.11)

- `power.*` (`modules/power/{default,sleep}.nix`) only wraps `systemsetup` with output sent to `/dev/null`. It has no per-power-source pmset keys and no `disablesleep`, and failures are invisible. `restartAfterPowerFailure` would silently no-op here (no `autorestart` in cap). So `server.nix` drives `pmset` directly.
- `services.tailscale` defines `com.tailscale.tailscaled` with `RunAtLoad` and **no `KeepAlive`**. Its package comes from nixpkgs: 1.90.9 (25.11) or 1.98.8 (pinned master). An override to 1.102.3 or 1.104.2 fails because those need Go ≥ 1.26.6 / 1.27.3, and the pin has Go 1.26.4 (tested).
- `services.openssh.enable` uses `launchctl enable/bootstrap|bootout/disable system/com.openssh.sshd`; `extraConfig` goes to `/etc/ssh/sshd_config.d/100-nix-darwin.conf`.
- Activation runs as root in this order: … `launchd`, `userLaunchd`, …, `power`, …, `homebrew`, `postActivation`. User agents are copied to `~/Library/LaunchAgents` and loaded with `launchctl asuser … load -w`. `launchd.*.command`/`script` jobs are already wrapped in `wait4path /nix/store`.

### Man pages and vendor docs

- `pmset(8)`: no mention of `disablesleep`. `autorestart` is documented, but this machine lacks the capability.
- `fdesetup(8)`: authrestart "deliberately stores at least one additional copy of a permanent FDE unlock key in both system memory and … the SMC". `-delayminutes 0` restarts immediately.
- `softwareupdate(8)`: `--stdinpass` and `--user` are "Apple silicon only"; `-R` restarts if required.
- `apple_ssh_and_filevault(7)` (macOS 26+): with Remote Login on, SSH **password** auth can unlock the data volume at pre-boot. The session then disconnects while services start. Apple's deployment guide limits this to previously joined open/WPA2-PSK Wi-Fi or open Ethernet. ([security guide](https://support.apple.com/guide/security/managing-filevault-sec8447f5049/web), [deployment guide](https://support.apple.com/guide/deployment/intro-to-filevault-dep82064ec40/web))
- [support.apple.com/120622](https://support.apple.com/en-us/120622): Apple silicon laptops start up when the lid opens or power is connected, unless `nvram BootPreference` is set. It's unset here.
- [Tailscale macOS variants](https://tailscale.com/kb/1065/macos-variants): only the open-source `tailscaled` runs before login and can be an SSH server. No auto-update. "Only recommended for unattended installs."
- [Tailscale SSH](https://tailscale.com/kb/1193/tailscale-ssh): `accept` vs `check` (default re-auth 12 h). `autogroup:member` can reach a tagged dst as any user incl. root if the rule allows it. Restarting tailscaled kills open Tailscale SSH sessions.
- [Key expiry](https://tailscale.com/kb/1028/key-expiry): expiry is disabled by default when a tag is applied for the first time and the device authenticates. That wasn't what we observed here. Moot now: ohnezahn is user-owned and its key expiry is disabled per device (§7).
- Grok Bot ([get started](https://cursor.com/docs/grok-bot/get-started), [security](https://cursor.com/docs/grok-bot/security)): an Anysphere Electron app (`com.anysphere.sand`, team `DCNK4UB866`). Bots run on a Cursor-hosted cloud computer. The desktop app lets them "run commands, read files, and move files" on the local machine, with per-command approval by default. It auto-updates.
- [batt README](https://github.com/charlie0129/batt): see §3.6.

### Claims I couldn't verify

1. Whether `fdesetup authrestart` ends at the login window or logs the user in. This decides whether agents, Dropbox and Simulator come back by themselves. *Answered 2026-10-25 (§7): FileVault unlocks unattended, but it stops at the login window.*
2. Whether `softwareupdate -i -a -R --stdinpass --user` restarts *through* FileVault. `LastLoginWindowHarvestMethod = ReqAuto` hints that macOS harvests credentials for its own auto-installs, but that's undocumented.
3. Whether wall power coming back with the cable already plugged in counts as "connecting power" for auto-boot after the battery hit 0%.
4. Which process TCC blames for commands in a **Tailscale SSH** session (likely `tailscaled`, an ad-hoc-signed Homebrew binary whose grant would break on every upgrade).
5. Whether `launchctl bootstrap … com.apple.screensharing.plist` still enables Screen Sharing on macOS 27 (*answered (§7): no. It listens but refuses connections*), and whether Screen Sharing gives a usable desktop with the lid closed and no display attached.
6. That `launchctl asuser` (the `gui` helper) puts commands in the Aqua domain from an SSH session, and whether `xcrun simctl` needs it.
7. The current TCC grants (DBs unreadable, see above).
8. A CLI for the macOS native charge limit (none found; `pmset -g battlimit` reports "No battery level limits set" although the limit is clearly enforced).
9. Whether Rex's embedded tsnet node (`ohnezahn-rex` peer) is an independent shell path when tailscaled is down. *Partly answered (§7): it's a separate tailnet node, and Rex-to-Rex over the tailnet works; not yet tested with tailscaled down.*

Each of these is a runbook item in §5.

---

## 2. Failure modes

| Event | What breaks | How you'd notice remotely | Unattended recovery |
|---|---|---|---|
| **Lid closed** (incl. thermals) | Laptop profile: clamshell sleep, seen twice on 10-24. Tailscale can't wake a sleeping Mac (`womp` is Ethernet magic packet only). Server: `disablesleep 1` keeps it up. Fanless chassis with the lid closed throttles under sustained load. | `ohnezahn-check --since "<t>"` counts `Sleep` events; `pmset -g therm` / `pmset -g thermlog`. | Prevention only: `disablesleep 1`, `sleep 0`, `standby 0`, `powernap 0`. Throttling self-limits. Keep it on a hard, ventilated surface. |
| **Wi-Fi drop** | Every remote path (no Ethernet today). | Peer offline in `tailscale status` from another node or in the admin console. No alerting (your choice). | macOS rejoins known networks. `server-watchdog` (root, every 5 min) power-cycles Wi-Fi after 2 failed gateway pings, at most every 30 min, and kickstarts tailscaled if `BackendState≠Running` twice. Better: a USB-C Ethernet adapter. |
| **Planned reboot** | GUI login: authrestart lands at the **login window** (verified, §7). tailscaled, sshd and Screen Sharing are up, but rex, Grok Bot, linkding-sync, Dropbox, AeroSpace and Simulator are not. | `ohnezahn-check`: "no GUI session". | `ohnezahn-update reboot` → `fdesetup authrestart` skips the FileVault unlock. Then log in via Screen Sharing over Tailscale (needs Screen Sharing switched on in System Settings beforehand); agents then start (`RunAtLoad`/`KeepAlive`). |
| **Unplanned reboot / power loss, FileVault on** | Power loss alone: the battery takes over (hours; `lowpowermode 1` on battery). Battery at 0 → shutdown; power back → boots, since `BootPreference` is unset (§1 #3). It boots to **FileVault pre-boot**: data volume locked, so **no tailscaled** (its state is on that volume) and no agents. Kernel freeze → `restartAfterFreeze`. | Node offline. Nothing on the machine can tell you. | From the **LAN only**: `ssh maxrn@192.168.1.122` with your **password** unlocks the volume (`apple_ssh_and_filevault(7)`). From outside you need a LAN jump host on the tailnet, and **none exists today**: the Pi at 192.168.1.4 isn't on it. Then GUI login via Screen Sharing. Until then this is a **known limit**: an unplanned reboot means unreachable until someone on the LAN unlocks. |
| **macOS update** | Server mode turns off `AutomaticallyInstallMacOSUpdates`, so no surprise nightly reboots. Downloads and critical/RSR updates stay on. | `ohnezahn-update status`. | `ohnezahn-update macos` (`softwareupdate --install --all --restart --stdinpass --user`). If it doesn't return on Tailscale in ~20 min, recover as for an unplanned reboot (§1 #2). |
| **App self-updates** | Grok Bot and Cursor (Squirrel/ShipIt: Grok Bot 0.68.1 and 0.70.2 helpers are running side by side right now), Rex, AlDente, Codex (Sparkle), Dropbox, Chrome (Keystone). The app quits or relaunches, or keeps running old code. A new version may ask for a new permission. TCC grants survive if bundle ID + Team ID stay the same (unverified per app). | `ohnezahn-check` (Grok Bot / rex server down); `~/Library/Logs/{grok-bot,rex-server}-agent.log`. | `grok-bot` and `rex-server` agents relaunch within 60 s. Nothing else is supervised. Brew-managed casks change only via `ohnezahn-update brew`. |
| **New permission prompt** ("Rex Server wants access to Dropbox") | A modal on the console waits indefinitely. SSH and background processes get a silent `Operation not permitted`. | `EPERM` in logs/output. TCC barely logs at default level. | None unattended: nix can't pre-grant (TCC.db is SIP-protected; only an MDM-delivered PPPC profile can, and none is available here). Remote fallback: Screen Sharing over Tailscale → click Allow. Pre-grant everything in §4 once, in person. |
| **Tailscale itself broken** | Crash → the brew plist's `KeepAlive` restarts it. Wedged (not `Running`) → watchdog kickstart. Logged out or **expired node key** (expiry currently disabled) → no self-recovery. ACL change → locked out. | Peer offline; `ohnezahn-check` from any other path. | Keep key expiry disabled (re-check after any re-auth). Fallbacks: keys-only sshd on the LAN; Rex's tsnet node (§1 #9). Remove the stale Standalone extension and VPN profiles (a second Tailscale stack fighting over routes/DNS). Upgrades restart tailscaled and drop Tailscale SSH sessions: `ohnezahn-update tailscale` warns first. |
| **Battery at 100 % around the clock** | Faster wear and swelling risk, worse with heat. | `ohnezahn-check` FAILs if > limit on AC; `ioreg -rn AppleSmartBattery`. | macOS native 80 % limit, firmware-enforced, independent of any app or login. Currently held at 80 (AlDente sets it via `useTahoeNativeLimit`). Check physically for swelling now and then. |

### FileVault vs auto-login

| | **A. FileVault on, no auto-login (recommended)** | B. FileVault off + auto-login |
|---|---|---|
| Planned reboot | `fdesetup authrestart`, then a Screen Sharing login (verified, §7) | Comes back fully logged in |
| Unplanned reboot | Unreachable until a LAN SSH password unlock (needs a jump host to do remotely) | Comes back fully, agents included |
| Laptop stolen | Disk unreadable without password/recovery key | Everything readable, and the thief boots straight into your session: tailnet node key (ohnezahn acts as *you* on the tailnet since §7), sops age key → all secrets, SSH keys, Dropbox, Cursor/Grok/Discord sessions, git credentials |
| Cost | Authrestart briefly keeps an unlock key in memory/SMC (fdesetup(8)); pre-boot SSH accepts password auth from the LAN | Auto-login is incompatible with FileVault, so B means disabling encryption on a machine that also travels |

**Recommendation: A.** This is a laptop that switches back to laptop duty, so B trades an occasional manual unlock for a total loss on theft. Close A's gap by putting an always-on LAN device (the Pi) on the tailnet as a jump host. An unplanned reboot then becomes `ssh -J pi maxrn@192.168.1.122` from anywhere.

### What nix manages vs. what it can't

| nix (both profiles explicit) | Not nix-manageable → one-time / in person |
|---|---|
| All pmset keys incl. `disablesleep` (activation script) | TCC grants (SIP-protected DB; §4) |
| Remote Login on/off + keys-only config + authorized keys | Native charge limit (no documented CLI) |
| | "Allow full disk access for remote users" (Remote Login pane); **Screen Sharing on/off** (System Settings only, §3.4) |
| `DevToolsSecurity`, `restartAfterFreeze`, `BootPreference` unset, `AutomaticallyInstallMacOSUpdates` | Tailscale key expiry, ACLs, tags (admin console) |
| `tailscale set --ssh=true` (server); the `tailscale` brew is declared | Removing the stale Tailscale extension and VPN profiles |
| Agents: rex-server, grok-bot (server); linkding-sync (both) | Stopping Grok Bot from also opening at login (harmless duplicate; `open -W` attaches) |
| Root watchdog; sops secrets | FileVault, Wi-Fi join, iCloud "Keep Downloaded", App Store sign-in for `mas` |

---

## 3. Implementation and security costs

### 3.1 Lid-closed operation
`pmset -a disablesleep 1` plus `sleep 0`, `disksleep 0`, `standby 0`, `powernap 0` on both sources, `lowpowermode 1` on battery. **Cost:** lid closed ≠ asleep ≠ locked. The machine stays on in a bag and gets hot, and anyone who opens the lid gets whatever the screen lock allows. Set Lock Screen → "Require password immediately".

### 3.2 tailscaled + Tailscale SSH
Homebrew's open-source tailscaled stays the daemon in **both** profiles; nix declares the brew, and server mode asserts `tailscale set --ssh=true`. Why not `services.tailscale`: no `KeepAlive`; nixpkgs is 4–12 minor versions **older** than the build that owns the state file, and newer builds don't compile with the pinned Go. Also, any switch that changes the daemon restarts tailscaled, killing the Tailscale SSH session that runs the switch. With brew, tailscaled never changes during `darwin-rebuild`. **Cost:** the tailnet policy is your SSH auth. Since §7 ohnezahn is user-owned, so your own-devices rule (typically `autogroup:member → autogroup:self`) decides who gets a shell; restrict `users` to `maxrn`. In the other direction, ohnezahn now *is* you on the tailnet: a compromise reaches every device and service you can reach. Keep node key expiry disabled (or set a calendar reminder).

### 3.3 Keys-only sshd fallback
`services.openssh.enable = true` (laptop: `false`). Settings: `PasswordAuthentication no`, `KbdInteractiveAuthentication no`, `AuthenticationMethods publickey`, `PermitRootLogin no`, `AllowUsers maxrn`, with one key in `server.sshAuthorizedKeys` (GitHub key 128219878, `SHA256:Kh5W…`). **Cost:** port 22 is open on the LAN (the application firewall is off). At FileVault pre-boot, sshd can't read this config, so the LAN can try your **login password**; make it strong.

### 3.4 Screen Sharing
**Not managed by nix.** Started via `launchctl`, it listens on 5900 but refuses every connection with "Screen Sharing is not permitted … Disable and re-enable Screen Sharing" (seen 2026-10-25). Only the toggle in System Settings › General › Sharing permits it, so turn it on there once and leave it; the laptop profile doesn't touch it either. `ohnezahn-check` can only see the port, and a refusing server offers the same RFB banner and security types as a permitting one, so it reports WARN at most; connecting is the real test. Your user is already in `com.apple.access_screensharing`. **Cost:** VNC on port 5900 is reachable from the whole LAN with password auth. To restrict it to the tailnet, add a pf anchor allowing 5900 only on `utun*`; not done here because a pf mistake can lock you out.

### 3.5 GUI apps and Simulator from SSH
- `gui <cmd>` runs a command in the Aqua domain via `sudo launchctl asuser`.
- More robust: work inside **rex**. `rex attach <session>` over SSH; the shells belong to the Rex server, which runs in the GUI domain with Rex Server's TCC grants.
- `DevToolsSecurity -enable` (laptop: `-disable`) lets lldb / `xcodebuild test` attach without the auth dialog. **Cost:** your processes can debug your other processes without a prompt.

### 3.6 Agents
| Agent | How | Notes |
|---|---|---|
| `org.nixos.rex-server` | `rex server run` from `Rex Server.app`, same args as the app; exits 0 if a server already answers (tested), `KeepAlive`, `ThrottleInterval 60`, Aqua only | Same bundle ID → same TCC identity as the app-spawned server |
| `org.nixos.grok-bot` | `/usr/bin/open -W -g -a "Grok Bot.app"` (`open(1)`: `-W` also waits on an already-running instance), `KeepAlive` | **Cost:** an always-on agent that can run commands here. In Grok Bot, keep local execution on per-command approval or "Never allow" unless needed |
| `dev.maxrn.linkding-sync` | Adopted with the **same label and identical plist** (verified). The key comes from sops, symlinked at `~/.config/blinks-sync/api_key` | In **both** profiles, because it ran in laptop mode before. The first switch replaces the plaintext key file with the symlink (value verified identical) |
| `org.nixos.server-watchdog` | root daemon, every 300 s | **Cost:** root job that toggles Wi-Fi and restarts tailscaled |

Secrets use **sops-nix** (age recipient = `~/.config/sops/age/keys.txt` on ohnezahn), decrypted at activation and by a boot-time daemon into `/run/secrets`. `sops-install-secrets` is built from `pkgs-unstable` because the 25.11 Go is too old. **Cost:** the age key is protected at rest only by FileVault and is mode 0644 today (`chmod 600` it). Losing it makes `secrets/ohnezahn.yaml` unreadable, so keep an offline copy. Encrypted secrets now live in a public repo, which is the normal sops model as long as the age key never gets committed. (Contrast with `key.raw.txt`.)

No external heartbeat, per your choice.

### 3.7 Restart after power failure
`pmset autorestart` isn't available on this hardware. The equivalent is Apple silicon's boot-on-power-connect: server mode deletes `nvram BootPreference` to keep it, and sets `restartAfterFreeze`. FileVault still stops the boot at pre-boot (§2).

### 3.8 80 % charge limit: AlDente vs batt
On firmware ≥ 20457.0.125 (this machine: 20457.1.29), the batt README says Apple gated the SMC charge keys. Both tools then end up on the **macOS native limit** (80–100 %).

| | AlDente (installed, Pro) | batt (`brew install batt`) |
|---|---|---|
| Mechanism here | `useTahoeNativeLimit = 1` → native limit | Falls back to the native limit; "adapter mode" cuts wall power for limits < 80 |
| Headless | GUI app + privileged helper; app must be running to change settings | Root daemon + CLI (`sudo batt limit 80`), works before login and over SSH |
| Updates | Sparkle self-update, needs GUI | brew |
| Attack surface | Closed source, privileged helper | Open source, root daemon |

For 80 % on this firmware, **neither is needed**. Set System Settings › Battery › Charge Limit = 80 % once; it's firmware-enforced and needs no login. Use batt only if you want < 80 % (adapter mode) or to adjust over SSH. Don't run both. Nothing for this is in nix (no documented CLI).

### 3.9 Remote updates: `ohnezahn-update`
| Subcommand | Does | Drops the connection? |
|---|---|---|
| `status` | `softwareupdate --list`, `brew outdated --greedy`, `mas outdated` | no |
| `nix [--pull] [--to …]` | build → `nvd diff` → confirm → `sudo darwin-rebuild switch --flake …#<profile>` → `ohnezahn-check` | no (tailscaled isn't touched) |
| `brew` | `brew upgrade --greedy` for everything except tailscale | no; running casks get replaced |
| `tailscale` | `brew upgrade tailscale` + `launchctl kickstart -k system/homebrew.mxcl.tailscale` | **yes**, ~10 s |
| `mas` | `mas upgrade` (needs App Store sign-in; mas 2.2.2 is outdated) | no |
| `macos` | `softwareupdate --install --all --restart --stdinpass --user $USER` | **yes**, reboot (§1 #2) |
| `reboot` | `fdesetup authrestart -delayminutes 0` | **yes** |

---

## 4. TCC: one-time in-person checklist

I couldn't read the grants (§1), so this is the list of what each component needs, not what's granted. Dump the truth from a terminal **that has Full Disk Access**:

```sh
sudo sqlite3 "/Library/Application Support/com.apple.TCC/TCC.db" 'select service, client, auth_value from access order by client'
sqlite3 ~/Library/Application\ Support/com.apple.TCC/TCC.db 'select service, client, auth_value from access order by client'
```

| Component (identity) | Grant | Why / caveat |
|---|---|---|
| Kanata (`/Applications/Nix Apps/Kanata.app`, ad-hoc via rcodesign) | Input Monitoring; Karabiner DriverKit driver (activated ✓) | Ad-hoc signature → **re-grant after every kanata version bump** (README steps) |
| AeroSpace (`/Applications/Nix Apps/AeroSpace.app`, `Signature=adhoc`) | Accessibility | Same caveat on nixpkgs updates |
| Dropbox | File Provider extension enabled (Login Items & Extensions); Accessibility if it asks; Files & Folders if backing up Desktop/Documents | Cask update changes nothing as long as the Team ID is stable |
| Cursor | Files & Folders (Desktop/Documents/Downloads); Local Network (dev servers/LAN); Automation if extensions drive apps | Integrated-terminal commands are attributed to Cursor |
| Xcode / Simulator | `DevToolsSecurity` (nix, server); `sudo xcodebuild -license accept`; `xcodebuild -runFirstLaunch` | Simulator itself needs no TCC for `simctl io screenshot` |
| Rex Server (`com.superlogical.rex.server`) | **Full Disk Access** (simplest: every shell in rex inherits it); otherwise per-provider "files managed by Dropbox/iCloud Drive", Files & Folders, Local Network | This is the "Rex Server wants access to Dropbox" prompt |
| Rex (`com.superlogical.rex`) | Notifications | |
| Grok Bot (`com.anysphere.sand`) | Files & Folders / FDA only if bots should touch local files; Accessibility / Screen Recording only on demand | Docs: the bot's computer is in the cloud; local access = commands and files |
| tailscaled (`/opt/homebrew/…/tailscaled`, ad-hoc) | FDA, if Tailscale SSH sessions need protected paths | Attribution unverified (§1 #4); grant breaks on each brew upgrade |
| sshd | Remote Login › "Allow full disk access for remote users" | Stable, Apple-signed |
| linkding-sync (`uv`) | None; instead set **Obsidian Clippings → Keep Downloaded** | Fixes the `EDEADLK` skips |
| AlDente helper | Already approved | Only if you keep AlDente |

**Remote fallback when a prompt appears:** Screen Sharing over Tailscale. On a Mac: `open vnc://ohnezahn.diplodocus-barley.ts.net`; on iPhone, any VNC client to the same name. It works at the login window too. If the lid-closed desktop is black (§1 #5), an HDMI dummy plug gives a framebuffer.

---

## 5. Verification

### 5.1 Static (done 2026-10-25)

| Check | Result |
|---|---|
| `nix flake check` | exit 0 |
| `darwin-rebuild build --flake .#ohnezahn` | exit 0 → `a94g7ggq…-darwin-system-25.11.ebec37a` |
| `darwin-rebuild build --flake .#ohnezahn-server` | exit 0 → `cww5z1s7…-darwin-system-25.11.ebec37a` |
| `nvd diff` HEAD (= `/run/current-system`) → `#ohnezahn` | +27 paths: sops-install-secrets (+ gnupg deps), ohnezahn-check/update, gui, nvd, linkding plist, etc files |
| `nvd diff #ohnezahn → #ohnezahn-server` | +5 paths: grok-bot, rex-server, server-watchdog plists and scripts |
| activation-script diff laptop ↔ server | only pmset values, sshd enable/disable, Screen Sharing, DevToolsSecurity, BootPreference, auto-install flag, `tailscale set --ssh`, 3 agents |
| linkding plist, hand-made vs generated (`jq -S`) | identical |
| sops roundtrip | decrypted value == `~/.config/blinks-sync/api_key` |
| shellcheck | `ohnezahn-{check,update}` (build-time) and the watchdog and rex-server scripts: clean |
| `OHNEZAHN_ETC=…/new-ohnezahn/etc/ohnezahn ohnezahn-check` against the live machine | **0 failures**: the laptop profile equals today's state |
| same against the `#ohnezahn-server` expectations | **19 failures**, exactly the settings the switch should change. The checker discriminates |

### 5.2 Runtime runbook (pass criteria are command outputs, not opinions)

Run R1 in person. Everything else runs remotely unless marked otherwise.

| # | Test | Steps | Pass |
|---|---|---|---|
| R1 | Switch to server | `sudo darwin-rebuild switch --flake ~/code/.dotfiles#ohnezahn-server` | `ohnezahn-check` exits 0 (battery and Screen Sharing may WARN), **and** `open vnc://ohnezahn.diplodocus-barley.ts.net` from another device reaches the login prompt |
| R2 | 2 h lid closed, SSH from cellular | Note `T0=$(date '+%F %H:%M')`; close lid on AC; after ≥ 2 h, phone on **cellular** (Wi-Fi off) → `ssh maxrn@ohnezahn` over Tailscale | `ohnezahn-check --since "$T0"` → `PASS 0 Sleep event(s)`, no thermal FAIL/WARN |
| R3 | Remote authrestart | `ohnezahn-update reboot` | `tailscale ping ohnezahn` answers within 10 min and SSH works. Record `launchctl print gui/501` → answers §1 #1. If absent: Screen Sharing login, then `ohnezahn-check` = 0 |
| R4a | Power pull | Unplug charger | `pmset -g batt` shows "Battery Power", still reachable, `lowpowermode` active |
| R4b | Power loss to boot (**in person once**) | `sudo shutdown -h now` with charger unplugged; plug it in | Mac boots (§1 #3); from the LAN, `ssh maxrn@192.168.1.122` + password unlocks; Tailscale back ≤ 5 min after unlock. From cellular without a jump host: **known limit** |
| R5 | Simulator over SSH | `xcrun simctl boot "<device>"`; `xcrun simctl io booted screenshot /tmp/s.png && file /tmp/s.png`, once plain, once via `gui` | `/tmp/s.png: PNG image data`, size > 0. Record which variant works (§1 #6) |
| R6 | Grok Bot across a reboot | after R3 | `ohnezahn-check`: `agent org.nixos.grok-bot loaded`, `Grok Bot running`. **Not** the external heartbeat you specified; skipped because you chose no uptime monitoring |
| R7 | Charge limit | ≥ 24 h on AC | `ohnezahn-check --battery-limit 80` → `PASS battery N% on AC (<= 80%)`; `ioreg -rn AppleSmartBattery | grep '"CurrentCapacity"'` ≤ 80 |
| R8 | Profile round trip | `pmset -g custom > /tmp/pm-before` (laptop) → `ohnezahn-update nix --to server` → `ohnezahn-check` → `ohnezahn-update nix --to laptop` → `ohnezahn-check` → `diff <(pmset -g custom) /tmp/pm-before` → back to server | Each `ohnezahn-check` exits 0, and the `diff` is empty |
| R9 | Permission prompt, resolved remotely | Over Tailscale SSH: `tccutil reset FileProviderDomain com.superlogical.rex.server` (service name unverified; `tccutil reset All com.superlogical.rex.server` resets *every* Rex Server grant). In a rex session: `ls ~/Library/CloudStorage/Dropbox-*` → `Operation not permitted`. Screen Sharing → Allow → rerun | Same `ls` lists files; nobody touched the machine |
| R10 | Wi-Fi self-heal | Reboot the router | Back on Tailscale ≤ 15 min after the router; `/var/log/server-watchdog.log` shows the action, if one was needed |
| R11 | Tailscale-down fallback | From the LAN: `ssh -i <key for SHA256:Kh5W…> maxrn@192.168.1.122`; then `ssh … -o PubkeyAuthentication=no` | First succeeds, second is refused (keys-only) |

---

## 6. Still to do in person

1. **First server switch (R1)**, with the sudo password at the keyboard.
2. **TCC grants** from §4. Turn on "Allow full disk access for remote users", then dump TCC.db to confirm.
3. **Charge limit:** System Settings › Battery › Charge Limit = 80 %. Decide whether to keep AlDente.
4. **Remove the stale Tailscale Standalone network extension** and the "Tailscale" / "Tailscale 2" VPN profiles.
5. ~~**Tailscale admin console:** disable key expiry; review the `tag:build-mac` SSH rule.~~ Done differently (§7): untagged, key expiry disabled. Still worth checking: policy rules that referenced `tag:build-mac` (e.g. remote builds) no longer match ohnezahn.
6. **Jump host:** put the Pi (192.168.1.4) on the tailnet and give ohnezahn a DHCP reservation (192.168.1.122). Without this, an unplanned reboot can't be recovered from outside.
7. **R4b** power-loss / FileVault pre-boot unlock test, once.
8. **Obsidian Clippings → Keep Downloaded** (linkding-sync `EDEADLK`).
9. `chmod 600 ~/.config/sops/age/keys.txt`, plus an offline backup of that key.
10. Confirm which device holds GitHub key `SHA256:Kh5W…`; add the phone's key if you SSH from it.
11. **git-crypt key in the public repo:** decide on removal and history rewrite. The fonts that key protected are already exposed.
12. Lock Screen: require password immediately. Placement: hard, ventilated surface; check now and then for battery swelling. Consider USB-C Ethernet.

---

## 7. Changes after the first write-up (2026-10-25)

- **ohnezahn is no longer tagged.** It was `tag:build-mac`, which made Tailscale treat it as owned by the tag. That blocked everything ohnezahn → your own devices: Taildrop ("peer is owned by a different user"), Rex to `shredder-rex`, and Tailscale SSH (tagged → user-owned isn't allowed). The admin console can't remove the last tag, so ohnezahn was re-authenticated with `sudo tailscale up --reset --force-reauth --ssh` and signed in as maxRN@github. Verified afterwards: `tags: null`, user `425445568916800`, same IP `100.115.33.68` and MagicDNS name, `KeyExpiry: null`, `RunSSH: true`, `ohnezahn-check` 0 failures.
  - **What works now:** `rex -S shredder-rex.diplodocus-barley.ts.net …` from ohnezahn (and `rex -S ohnezahn-rex…` from shredder), and Taildrop between the two.
  - **What it costs:** ohnezahn acts as you on the tailnet (§2, §3.2), and policy rules that targeted `tag:build-mac` no longer apply to it.
  - **Alternative not taken:** keys-only sshd on shredder, admitting only ohnezahn's key from tailnet addresses (validated with `sshd -t`/`sshd -T`). It's in `git stash` as "shredder sshd for ohnezahn (reverted in favour of untagging ohnezahn)".
- **sops** only uses the age key (`age.sshKeyPaths = gnupg.sshKeyPaths = [ ]`). The defaults also tried `/etc/ssh/ssh_host_*_key`, which macOS only creates on first sshd use; that caused "Cannot read ssh key" noise and pulled in gnupg.
- **`~/.local/bin/rex` is a home-manager script now, not a symlink** (`home/default.nix`, both Macs). Rex moved its CLI twice in a week: `Rex Beta.app/Contents/MacOS/Rex` (crashed when launched through a symlink: missing `swift-ghostty_GhosttyRender` bundle), then `Contents/Helpers/Rex Server.app` (`Rex Server.rex` on shredder), then `~/Library/Application Support/com.superlogical.rex/RexServer/Versions/Current/…` after the 2026-10-25 update. That last move broke the `rex-server` agent (exit 127 every 60 s) and the check's probe. The script tries `$REX_BIN_DIR` (exported by Rex in its terminals), then `Versions/Current`, then the old in-app paths, and execs the first that exists by absolute path. The agent and `ohnezahn-check` call it too.
- **hermes** (Discord agent, gateway watchdog, iOS relay) was uninstalled: agents unloaded, plists, `~/.hermes` and `~/hermes-local-relay` deleted. Its Discord/Google credentials need revoking on the provider side.
- **Done in person:** age key `chmod 600`, Lock Screen immediate, stale Tailscale VPN profiles removed and the Standalone extension disabled, Clippings set to Keep Downloaded (linkding-sync created 60 previously skipped links on its next run).
- **Reboot test (R3), 2026-10-25 16:40:** after `ohnezahn-update reboot`, ohnezahn came back on Tailscale (direct, LAN) with nobody at the Mac, so **authrestart unlocks FileVault unattended**. But the Rex server, which only runs in a GUI login, was still down 11 min later, so **it stops at the login window**. Planned reboots therefore always end with one Screen Sharing login.
- **Screen Sharing via `launchctl` doesn't work.** Port 5900 listened, but the client said "Screen Sharing is not permitted on ohnezahn… Disable and re-enable Screen Sharing or Remote Management in System Settings". The module no longer manages it in either profile (§3.4), and the check now WARNs instead of claiming PASS from the open port. Fix: at the Mac, toggle it off and on in System Settings › General › Sharing.
