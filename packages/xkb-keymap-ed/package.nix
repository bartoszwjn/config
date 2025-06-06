{
  lib,
  runCommand,
  xkbcomp,
}:
runCommand "xkb-keymap-ed"
  {
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./keymap.xkb
        ./symbols
        ./types
      ];
    };

    nativeBuildInputs = [ xkbcomp ];
  }
  ''
    xkbcomp -xkb -I$src $src/keymap.xkb keymap.xkb
    install -D -m 644 keymap.xkb $out/keymap.xkb
  ''
