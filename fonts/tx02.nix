{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "tx02";
  version = "1.0";

  src = ./TX-02;
  dontPatch = true;
  dontConfigure = true;
  dontBuild = true;
  doCheck = false;
  dontFixup = true;

  installPhase = ''
    runHook preInstall
    install -Dm644 -t $out/share/fonts/opentype/ *.otf
    runHook postInstall
  '';

  meta = with lib; {
    description = "TX-02 BerkeleyMono 2.0";
    homepage = "https://usgraphics.com/products/berkeley-mono";
    platforms = platforms.all;
  };
}
