{
  lib,
  stdenv,
  fetchFromGitHub,
  pkg-config,
  cmake,
  qt6Packages,
  boost,
  libnotify,
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
    qt6Packages.wrapQtAppsHook
  ];
  buildInputs = [
    boost
    libnotify
    openssl
    qt6Packages.qt5compat
    qt6Packages.qtbase
    qt6Packages.qtimageformats
    qt6Packages.qtkeychain
    qt6Packages.qtsvg
    qt6Packages.qttools
  ] ++ lib.optional stdenv.isLinux qt6Packages.qtwayland;

  cmakeFlags = [
    (lib.strings.cmakeBool "CHATTERINO_UPDATER" false)
    (lib.strings.cmakeBool "USE_SYSTEM_QTKEYCHAIN" true)
  ];

  env = {
    GIT_RELEASE = version;
    GIT_COMMIT = source-info.rev;
    GIT_HASH = source-info.rev;
  };

  meta = {
    license = lib.licenses.mit;
    mainProgram = "chatterino";
  };
}
