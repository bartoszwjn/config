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
}:
let
  source = builtins.fromJSON (builtins.readFile ./source.json);
  version = "unstable-${source.commitDate}";
in
mkDerivation {
  pname = "chatterino2";
  inherit version;
  src = fetchFromGitHub {
    inherit (source)
      owner
      repo
      rev
      hash
      fetchSubmodules
      ;
    # use the same store path as `nix-prefetch-github`
    name = "${source.repo}-${builtins.substring 0 7 source.rev}";
  };
  nativeBuildInputs = [
    pkg-config
    cmake
    wrapQtAppsHook
  ];
  buildInputs = [
    boost
    libsecret
    openssl
    qtbase
    qtimageformats
    qtmultimedia
    qtsvg
    qttools
  ];

  cmakeFlags = [ (lib.strings.cmakeBool "CHATTERINO_UPDATER" false) ];

  env = {
    GIT_RELEASE = version;
    GIT_COMMIT = source.rev;
    GIT_HASH = source.rev;
  };

  meta = {
    license = lib.licenses.mit;
  };
}
