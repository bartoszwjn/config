{
  lib,
  mkDerivation,
  fetchFromGitHub,
  pkg-config,
  cmake,
  wrapQtAppsHook,
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
  version = "2.4.6-unstable-2023-11-11";
  rev = "95620e6e10b05816d3b8828590d19cd0a4a5b823";
  hash = "sha256-j9wiCuVw0KhGKAEN2mQ+ShVD0eWf5GbEwC3QZqoNUFE=";
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
    nativeBuildInputs = [pkg-config cmake wrapQtAppsHook];
    buildInputs = [boost libsecret openssl qtbase qtimageformats qtmultimedia qtsvg qttools];

    env = {
      GIT_RELEASE = version;
      GIT_COMMIT = rev;
      GIT_HASH = rev;
    };

    meta = {
      license = lib.licenses.mit;
    };
  }
