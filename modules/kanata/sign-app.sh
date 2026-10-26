# Usage: kanata-sign-app <source.app> <dest.app> <state-dir>
#
# Copies the app bundle out of the Nix store and signs it with a per-machine
# self-signed certificate. TCC pins an ad-hoc signed app to its exact binary
# hash, so every kanata update dropped the Input Monitoring grant. A
# certificate-based signature keeps the designated requirement stable.

src=$1
dest=$2
state=$3

keychain="$state/codesign.keychain-db"
password_file="$state/keychain-password"
stamp="$state/signed-from"
common_name="kanata-codesign"

cert_hash() {
  /usr/bin/security find-certificate -c "$common_name" -Z "$keychain" 2>/dev/null |
    awk '/^SHA-1 hash:/ { print $3 }'
}

install -d -m 700 "$state"

if [[ ! -f "$password_file" || -z "$(cert_hash)" ]]; then
  echo "kanata: creating code signing certificate in $keychain" >&2
  tmp=$(mktemp -d)
  trap 'rm -rf "$tmp"' EXIT
  rm -f "$keychain"
  (umask 077 && openssl rand -hex 32 >"$password_file")
  openssl req -x509 -newkey rsa:2048 -nodes -days 36500 \
    -subj "/CN=$common_name" \
    -addext "keyUsage=critical,digitalSignature" \
    -addext "extendedKeyUsage=critical,codeSigning" \
    -addext "basicConstraints=critical,CA:false" \
    -keyout "$tmp/key.pem" -out "$tmp/cert.pem" 2>/dev/null
  /usr/bin/security create-keychain -p "$(<"$password_file")" "$keychain"
  /usr/bin/security set-keychain-settings "$keychain"
  /usr/bin/security unlock-keychain -p "$(<"$password_file")" "$keychain"
  /usr/bin/security import "$tmp/key.pem" -k "$keychain" -T /usr/bin/codesign >/dev/null
  /usr/bin/security import "$tmp/cert.pem" -k "$keychain" >/dev/null
  /usr/bin/security set-key-partition-list -S apple-tool:,apple: -s \
    -k "$(<"$password_file")" "$keychain" >/dev/null
fi

hash=$(cert_hash)
requirement="identifier \"org.nixos.kanata\" and certificate leaf = H\"$hash\""

if [[ "$(cat "$stamp" 2>/dev/null)" == "$src" ]] &&
  /usr/bin/codesign --verify --strict -R="$requirement" "$dest" 2>/dev/null; then
  exit 0
fi

staging="$(dirname "$dest")/.$(basename "$dest").new"
rm -rf "$staging"
cp -R "$src" "$staging"
chmod -R u+w "$staging"
/usr/bin/security unlock-keychain -p "$(<"$password_file")" "$keychain"
/usr/bin/codesign --force --keychain "$keychain" --sign "$hash" "$staging"
/usr/bin/codesign --verify --strict -R="$requirement" "$staging"
rm -rf "$dest"
mv "$staging" "$dest"
printf '%s\n' "$src" >"$stamp"
echo "kanata: signed $dest" >&2
