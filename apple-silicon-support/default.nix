{ pkgs, ... }:

{
  imports = [
    ./modules/default.nix
  ];

  # Fix niri failing to initialize EGL
  # programs.niri.package = pkgs.niri.override ({
    # libgbm = pkgs.mesa-asahi-edge;
  # });

  boot = {
    kernelPatches = [
      {
        name = "bcachefs-config";
        patch = null;
        extraConfig = ''
          BCACHEFS_FS m
        '';
      }
    ];
    initrd.supportedFilesystems = [ "bcachefs" ];
    supportedFilesystems = [ "bcachefs" ];
  };
}
