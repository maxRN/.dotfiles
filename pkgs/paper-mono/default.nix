{
  lib,
  stdenvNoCC,
  fetchurl,
  unzip,
  python3,
  slashedZero ? false,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "paper-mono" + lib.optionalString slashedZero "-slashed-zero";
  version = "1.000";

  src = fetchurl {
    url = "https://github.com/paper-design/paper-mono/releases/download/v${finalAttrs.version}/paper-mono-v${finalAttrs.version}.zip";
    hash = "sha256-hkJlKYXch79M/QfImUKJnmEcPHdPwlKEwN1P6GqZOhM=";
  };

  nativeBuildInputs = [
    unzip
  ]
  ++ lib.optionals slashedZero [
    (python3.withPackages (ps: [ ps.fonttools ]))
  ];

  dontConfigure = true;
  dontBuild = !slashedZero;

  buildPhase = lib.optionalString slashedZero ''
    runHook preBuild
    python3 ${./slashed-zero.py} fonts/otf fonts/slashed-zero
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    install -Dm644 fonts/${
      if slashedZero then "slashed-zero" else "otf"
    }/*.otf -t "$out/share/fonts/opentype"
    install -Dm644 OFL.txt -t "$out/share/licenses/paper-mono"

    runHook postInstall
  '';

  meta = {
    description =
      "Monospace typeface by Paper for design and code"
      + lib.optionalString slashedZero " with slashed zero enabled by default";
    homepage = "https://github.com/paper-design/paper-mono";
    license = lib.licenses.ofl;
    platforms = lib.platforms.all;
  };
})
