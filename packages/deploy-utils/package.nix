{
  lib,
  stdenvNoCC,
  nushell,
}:

let
  fs = lib.fileset;
in

stdenvNoCC.mkDerivation {
  name = "deploy-utils";

  src = fs.toSource {
    root = ./.;
    fileset = fs.fileFilter (file: file.hasExt "nu") ./.;
  };

  buildInputs = [ nushell ];

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r $src $out/src
    mkdir $out/bin
    ln -s $out/src/main.nu $out/bin/deploy-utils

    runHook postInstall
  '';

  meta = {
    mainProgram = "deploy-utils";
  };
}
