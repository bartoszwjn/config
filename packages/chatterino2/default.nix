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
  version = "2.4.6-unstable-2023-12-03";
  rev = "44abe6b487272ec11f0e5f2cd05e7bd635b0bddc";
  hash = "sha256-JZTBbo3tJg2h0OjEK2rhHQeIAE8a9psUS7YltxE5lOw=";
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

    cmakeFlags = [(lib.strings.cmakeBool "CHATTERINO_UPDATER" false)];

    env = {
      GIT_RELEASE = version;
      GIT_COMMIT = rev;
      GIT_HASH = rev;
    };

    meta = {
      license = lib.licenses.mit;
    };
  }
