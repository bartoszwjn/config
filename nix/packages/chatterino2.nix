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
}:
mkDerivation rec {
  pname = "chatterino2";
  version = "2023-03-06";
  src = fetchFromGitHub {
    owner = "Chatterino";
    repo = pname;
    rev = "01a4861d7602b75b1f553f3adc9e6e622761c089";
    hash = "sha256-wV8/6W2el0HWJdtLqD06fusRrTdG6TDbyOAMu3pTrWA=";
    fetchSubmodules = true;
  };
  nativeBuildInputs = [pkg-config cmake];
  buildInputs = [boost libsecret openssl qtbase qtimageformats qtmultimedia qtsvg qttools];
}
