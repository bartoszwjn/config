{
  lib,
  mkDerivation,
  fetchFromGitHub,
  pkg-config,
  cmake,
  boost,
  libsecret,
  openssl,
  qtbase,
  qtimageformats,
  qtmultimedia,
  qtsvg,
  qttools,
}: let
  pname = "chatterino2";
  version = "2023-05-14";
  rev = "4fa2cc26c9bffd5a6c770380c8a8bceb7368edbf";
  hash = "sha256-eclxOiWxOhjl+3k29f57+fnPJlPn6G+gDz0s9o53jns=";
in
  mkDerivation {
    inherit pname version;
    src = fetchFromGitHub {
      owner = "Chatterino";
      repo = pname;
      inherit rev hash;
      fetchSubmodules = true;
      # use the same store path as `nix-prefetch-github`
      name = "${pname}-${builtins.substring 0 7 rev}";
    };
    nativeBuildInputs = [pkg-config cmake];
    buildInputs = [boost libsecret openssl qtbase qtimageformats qtmultimedia qtsvg qttools];
  }
