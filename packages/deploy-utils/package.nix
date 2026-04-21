{
  lib,
  writers,
}:

let
  fs = lib.fileset;

  src = fs.toSource {
    root = ./.;
    fileset = ./src;
  };
in

writers.writeNuBin "deploy-utils" { } ''
  source ${src}/src/main.nu
''
