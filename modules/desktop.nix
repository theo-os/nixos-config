{ lib, pkgs, ... }:
{
  imports = [
  ];

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    xclip
    dunst
    bemenu
    ffmpeg
    blender
    legcord
    mpv
    obs-studio
    chromium
    brightnessctl
    pulsemixer
    zed-editor
    vulkan-tools
  ];

  programs.niri.enable = true;

  nixpkgs.overlays = [
    (final: previous: {
      mpv = previous.mpv.override {
        scripts = [ final.mpvScripts.mpv-discord ];
      };

      # xorg = previous.xorg // {
      #   xorgserver = final.xlibre-xserver;
      # };
    })
  ];

  security.wrappers = {
    ffmpeg = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.ffmpeg}/bin/ffmpeg";
    };
  };

  services.kanata = {
    enable = true;
  };

  services.printing.enable = true;

  security.rtkit.enable = true;
  services.pulseaudio.enable = false;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    alsa.support32Bit = false;
    jack.enable = false;
  };

}
