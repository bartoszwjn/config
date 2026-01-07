{
  lib,
  runCommand,
  libxkbcommon,
}:
runCommand "xkb-keymap-custom.xkb"
  {
    src = lib.fileset.toSource {
      root = ./.;
      fileset = lib.fileset.unions [
        ./symbols
        ./types
      ];
    };
    nativeBuildInputs = [ libxkbcommon ];
  }
  ''
    xkbcli compile-keymap --include $src --include-defaults --layout custom > keymap.xkb
    install -T -m 644 keymap.xkb $out
  ''
