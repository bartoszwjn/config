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
  version = "2023-04-16";
  rev = "8124ab439ce34bacc68e9a8cd4c454dc1a2cd2f9";
  hash = "sha256-y3ariu0o7KZQTWi+ktagXLS6phhYFF+JzVWoCQA7qiA=";
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
