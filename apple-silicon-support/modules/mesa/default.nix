{ options, config, pkgs, lib, ... }:
{
  config = let
    isMode = mode: (config.hardware.asahi.useExperimentalGPUDriver
        && config.hardware.asahi.experimentalGPUInstallMode == mode);
  in lib.mkIf config.hardware.asahi.enable (lib.mkMerge [
    {
      # required for proper DRM setup even without GPU driver
      services.xserver.config = ''
        Section "OutputClass"
            Identifier "appledrm"
            MatchDriver "apple"
            Driver "modesetting"
            Option "PrimaryGPU" "true"
        EndSection
      '';
    }
    (lib.mkIf config.hardware.asahi.useExperimentalGPUDriver {
      # install the Asahi Mesa version
      hardware.graphics.package = config.hardware.asahi.pkgs.mesa-asahi-edge;
      # required for in-kernel GPU driver
      hardware.asahi.withRust = true;
    })
  ]);

  options.hardware.asahi.useExperimentalGPUDriver = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Use the experimental Asahi Mesa GPU driver.

      Do not report issues using this driver under NixOS to the Asahi project.
    '';
  };
}
