{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "secretive";
  version = "4.0.0";

  src = fetchzip {
    url = "https://github.com/maxgoedjen/secretive/releases/download/v${finalAttrs.version}/Secretive.zip";
    hash = "sha256-AP/ubwV9h/9EYj7J6psSUAkzBjee3QB3a4/7hv7nWYk=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    cp -R Secretive.app "$out/Applications/"

    runHook postInstall
  '';

  meta = {
    description = "Store SSH keys in the Secure Enclave";
    homepage = "https://github.com/maxgoedjen/secretive";
    changelog = "https://github.com/maxgoedjen/secretive/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
