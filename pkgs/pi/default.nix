{
  callPackage,
  fetchFromGitHub,
}:
let
  version = "1.4.0";
  source = fetchFromGitHub {
    owner = "earendil-works";
    repo = "pi";
    rev = "v${version}";
    hash = "sha256-N9NOpiiZTbOMDMV+CxvJAgtLjJJ1/8NJBGS0cFHkhsc=";
  };
in
# Reuse the release's build recipe and pinned npm dependencies/model catalog.
callPackage (source + "/nix/package.nix") { inherit source; }
