# Compares the machine's live state with what the active profile (laptop|server)
# declares. Prints PASS/FAIL/WARN per check; exit status = number of FAILs.
#
#   ohnezahn-check                     # all checks for the active profile
#   ohnezahn-check --since "2026-10-25 15:00"   # also: zero sleeps since then
#   ohnezahn-check --battery-limit 80  # FAIL if on AC and above the limit
#
# Read-only; needs no sudo (sshd -T is skipped without it).

since=""
limit=80
while [ $# -gt 0 ]; do
  case "$1" in
    --since) since="$2"; shift 2 ;;
    --battery-limit) limit="$2"; shift 2 ;;
    *) echo "usage: ohnezahn-check [--since 'YYYY-MM-DD HH:MM'] [--battery-limit N]" >&2; exit 64 ;;
  esac
done

# OHNEZAHN_ETC lets you dry-run against a built, not yet activated, system:
#   OHNEZAHN_ETC=./result/etc/ohnezahn ohnezahn-check
etc=${OHNEZAHN_ETC:-/etc/ohnezahn}
profile=$(cat "$etc/profile")
fails=0
pass() { printf 'PASS  %s\n' "$*"; }
fail() { printf 'FAIL  %s\n' "$*"; fails=$((fails + 1)); }
warn() { printf 'WARN  %s\n' "$*"; }
# expect <pass message> <fail message> <command...>
expect() {
  local ok_msg=$1 bad_msg=$2
  shift 2
  if "$@"; then pass "$ok_msg"; else fail "$bad_msg"; fi
}
# The helpers below are only called through `expect "$@"`, which shellcheck can't follow.
# shellcheck disable=SC2329
quiet() { "$@" >/dev/null 2>&1; }
# shellcheck disable=SC2329
port_open() { /usr/bin/nc -z -G 2 127.0.0.1 "$1" >/dev/null 2>&1; }
# shellcheck disable=SC2329
port_closed() { ! port_open "$1"; }

echo "profile: $profile ($(date '+%F %T %z'))"

# --- power: pmset -g custom must match power.expected exactly
actual=$(
  {
    /usr/bin/pmset -g custom | awk '
      /^Battery Power:/ { s = "Battery"; next }
      /^AC Power:/      { s = "AC"; next }
      s != "" && NF >= 2 { print s, $(NF-1), $NF }'
    /usr/bin/pmset -g | awk '/SleepDisabled/ { print "System SleepDisabled", $2 }'
  }
)
power_ok=1
while read -r section key want; do
  got=$(printf '%s\n' "$actual" | awk -v s="$section" -v k="$key" '$1 == s && $2 == k { print $3 }')
  if [ "$got" != "$want" ]; then
    fail "pmset $section $key: want $want, got ${got:-<missing>}"
    power_ok=0
  fi
done < "$etc/power.expected"
if [ "$power_ok" = 1 ]; then
  pass "pmset -g custom matches $profile profile ($(wc -l < "$etc/power.expected" | tr -d ' ') keys)"
fi

# --- sleeps since a point in time (lid-closed soak test)
if [ -n "$since" ]; then
  sleeps=$(/usr/bin/pmset -g log | awk -v t="$since" '
    $1 " " substr($2, 1, 5) >= t && $4 == "Sleep" { n++ } END { print n + 0 }')
  if [ "$profile" = server ] && [ "$sleeps" -gt 0 ]; then
    fail "$sleeps Sleep event(s) in pmset -g log since $since"
    /usr/bin/pmset -g log | awk -v t="$since" '$1 " " substr($2, 1, 5) >= t && $4 == "Sleep"' | tail -3
  else
    pass "$sleeps Sleep event(s) since $since"
  fi
fi

# --- thermals (fanless MacBook Air, lid closed)
therm=$(/usr/bin/pmset -g therm)
if printf '%s' "$therm" | grep -q 'No thermal warning level has been recorded'; then
  pass "no thermal warning recorded"
else
  warn "thermal state: $(printf '%s' "$therm" | tr '\n' ' ')"
fi

# --- FileVault
if /usr/bin/fdesetup isactive >/dev/null 2>&1; then pass "FileVault on"; else warn "FileVault off"; fi

# --- Tailscale
ts=/opt/homebrew/bin/tailscale
if [ -x "$ts" ] && st=$("$ts" status --json 2>/dev/null); then
  backend=$(printf '%s' "$st" | jq -r .BackendState)
  online=$(printf '%s' "$st" | jq -r .Self.Online)
  expiry=$(printf '%s' "$st" | jq -r '.Self.KeyExpiry // "none"')
  expect "tailscale Running, online" "tailscale BackendState=$backend online=$online" \
    [ "$backend:$online" = Running:true ]
  if [ "$expiry" != none ]; then warn "tailscale node key expires $expiry (disable key expiry in the admin console)"; fi
  if [ "$profile" = server ]; then
    runssh=$("$ts" debug prefs 2>/dev/null | jq -r .RunSSH)
    expect "Tailscale SSH enabled" "Tailscale SSH RunSSH=$runssh" [ "$runssh" = true ]
  fi
else
  fail "tailscale CLI missing or tailscaled not answering"
fi
if /usr/bin/pgrep -qf 'io.tailscale.ipn.macsys.network-extension'; then
  warn "Standalone Tailscale network extension is running next to tailscaled"
fi

# --- sshd reachability matches profile
if [ "$profile" = server ]; then
  expect "sshd listening on :22" "sshd not listening on :22" port_open 22
else
  expect "sshd off" "sshd listening on :22 in laptop profile" port_closed 22
fi

# --- Screen Sharing: not managed by nix. A listening port doesn't prove connections
# are permitted (launchctl-started sharing listens and then refuses logins), so
# this is a WARN at most; R1 in the doc is the real test.
if port_open 5900; then
  warn "Screen Sharing listening on :5900 (permitted only if switched on in System Settings; verify by connecting)"
elif [ "$profile" = server ]; then
  fail "Screen Sharing off: turn it on in System Settings > General > Sharing"
fi
if [ "$profile" = server ] && sudo -n true 2>/dev/null; then
  pa=$(sudo -n /usr/sbin/sshd -T 2>/dev/null | awk '$1 == "passwordauthentication" { print $2 }')
  expect "sshd PasswordAuthentication no" "sshd PasswordAuthentication=$pa" [ "$pa" = no ]
fi

# --- server-only expectations
if [ "$profile" = server ]; then
  uid=$(id -u)
  if launchctl print "gui/$uid" >/dev/null 2>&1; then
    pass "GUI (Aqua) session for uid $uid exists"
    for label in org.nixos.rex-server org.nixos.grok-bot dev.maxrn.linkding-sync; do
      expect "agent $label loaded" "agent $label not loaded" quiet launchctl print "gui/$uid/$label"
    done
    expect "rex server answers" "rex server not answering" quiet "$HOME/.local/bin/rex" --autostart=false --timeout 5s ls
    expect "Grok Bot running" "Grok Bot not running" /usr/bin/pgrep -xq 'Grok Bot'
  else
    fail "no GUI session (nobody logged in): agents, Dropbox, Simulator are down; log in via Screen Sharing"
  fi

  expect "server-watchdog loaded" "server-watchdog not loaded" quiet launchctl print system/org.nixos.server-watchdog

  if /usr/sbin/nvram BootPreference >/dev/null 2>&1; then
    fail "nvram BootPreference is set; Mac won't boot on power connect"
  else
    pass "BootPreference unset (boots on power connect)"
  fi

  auto=$(defaults read /Library/Preferences/com.apple.SoftwareUpdate AutomaticallyInstallMacOSUpdates 2>/dev/null || echo unset)
  expect "macOS updates not auto-installed" "AutomaticallyInstallMacOSUpdates=$auto" [ "$auto" = 0 ]
fi

# --- battery charge limit (only meaningful on AC)
batt=$(/usr/sbin/ioreg -rn AppleSmartBattery)
cap=$(printf '%s' "$batt" | awk -F' = ' '/"CurrentCapacity" =/ { print $2; exit }')
ext=$(printf '%s' "$batt" | awk -F' = ' '/"ExternalConnected" =/ { print $2; exit }')
if [ "$ext" = Yes ]; then
  if [ "$cap" -le "$limit" ]; then pass "battery ${cap}% on AC (<= ${limit}%)"; else fail "battery ${cap}% on AC (> ${limit}%): charge limit not enforced"; fi
else
  warn "on battery (${cap}%), charge-limit check skipped"
fi

echo "failures: $fails"
exit "$fails"
