{
  lib,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "berkeley-mono";
  version = "1.0";

  src = ./../fonts/BerkeleyMono;
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
    description = "BerkeleyMono";
    homepage = "https://usgraphics.com/products/berkeley-mono";
    platforms = platforms.all;
  };
}
