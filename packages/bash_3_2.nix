{
  lib,
  stdenv,
  fetchurl,
  bison,
}:
let
  pname = "bash";
  version = "3.2.57";
  hash = "sha256-P6na+F6/NQaPCQzlEoPd7rPHXrW8cLGkp8sFhov+BqQ=";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "mirror://gnu/bash/bash-${version}.tar.gz";
    inherit hash;
  };

  buildInputs = [ bison ];

  env.NIX_CFLAGS_COMPILE = ''
    -Wno-error=format-security
  '';

  meta = {
    license = lib.licenses.gpl2Only;
  };
}
