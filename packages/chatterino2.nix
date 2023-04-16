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
  version = "2023-03-28";
  rev = "7aaec5f5c6a47f4ebaa21aa1c9df4d740b89ab30";
  hash = "sha256-Eauiq7juDQSEU/oZxWj+K4pqlJF9yslDz5yn3ylejeo=";
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
