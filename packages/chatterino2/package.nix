{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  qt6,
  boost,
  libsecret,
  openssl,
}:
let
  source-info = lib.importJSON ./source-info.json;
  version = "unstable-${source-info.commitDate}";
in
stdenv.mkDerivation {
  pname = "chatterino2";
  inherit version;

  src = fetchFromGitHub {
    inherit (source-info) owner repo fetchSubmodules;
    inherit (source-info) rev hash;
    # use the same store path as `nix-prefetch-github`
    name = "${source-info.repo}-${builtins.substring 0 7 source-info.rev}";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.wrapQtAppsHook
  ];
  buildInputs = [
    boost
    libsecret
    openssl
    qt6.qt5compat
    qt6.qtbase
    qt6.qtimageformats
    qt6.qtsvg
    qt6.qttools
  ] ++ lib.optional stdenv.isLinux qt6.qtwayland;

  cmakeFlags = [
    (lib.strings.cmakeBool "BUILD_WITH_QT6" true)
    (lib.strings.cmakeBool "CHATTERINO_UPDATER" false)
  ];

  env = {
    GIT_RELEASE = version;
    GIT_COMMIT = source-info.rev;
    GIT_HASH = source-info.rev;
  };

  meta = {
    license = lib.licenses.mit;
  };
}
