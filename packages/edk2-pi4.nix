{
  lib,
  edk2,
  fetchFromGitHub,
  llvmPackages_latest,
  acpica-tools,
}:

let
  edk2-platforms-src = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2-platforms";
    rev = "52e9811d6ffb94b25bce35bc723da4697185edf2";
    hash = "sha256-n7WORWoa7KzkxOtaTxXThWk5trqvHZ0/ntifOuk5kHI=";
  };

  edk2-src = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2";
    rev = "eefd4fdb788f1b126719bd621449acc976b8e795";
    hash = "sha256-s0z7Vja3vHbV/lp99qkR6LTEa3iPRLoPFsN1EDJxuNQ=";
    fetchSubmodules = true;
  };

  edk2-non-osi-src = fetchFromGitHub {
    owner = "tianocore";
    repo = "edk2-non-osi";
    rev = "ea2040c2d4e2200557e87b9f9fbd4f8fb7a2b6e8";
    hash = "sha256-gQY4lQGy9mIQOk+IqzFW31vM7S9K1TRVLjZ6iFVGgXs=";
  };
in
(
  (
    (edk2.override {
      stdenv = llvmPackages_latest.stdenv;
    }).mkDerivation
    "${edk2-platforms-src}/Platform/RaspberryPi/RPi4/RPi4.dsc"
    {
      name = "tianocore-pi4";
      buildType = "CLANGDWARF";
      nativeBuildInputs = [
        llvmPackages_latest.llvm
        llvmPackages_latest.lld
        acpica-tools
      ];
      preBuild = ''
        export PACKAGES_PATH=${edk2-src}:${edk2-platforms-src}:${edk2-non-osi-src}
      '';
    }
  ).overrideAttrs
  {
    src = edk2-src;
  }
)
