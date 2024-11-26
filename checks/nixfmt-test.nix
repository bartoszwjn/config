{
  src,
  runCommandLocal,
  nixfmt-rfc-style,
}:
runCommandLocal "nixfmt-test"
  {
    nativeBuildInputs = [ nixfmt-rfc-style ];
  }
  ''
    cd ${src}
    nixfmt --check .
    touch $out
  ''
