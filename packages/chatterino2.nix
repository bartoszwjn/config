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
  version = "2.4.4-unstable-2023-08-07";
  rev = "e0417bc87e08aac9b8229d4ede949a19fbd77b79";
  hash = "sha256-Eq8/gIYKquR7xWir1vb2dfvBeTTDq6g/HA125FE8cfQ=";
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

    meta = {
      license = lib.licenses.mit;
    };
  }
