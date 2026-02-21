{ pkgs, ... }:
{
  imports = [
  ];

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    firefox
    wl-clipboard
    mako
    bemenu
    ffmpeg
    blender
    legcord
    zed-editor
    mpv
    obs-studio
  ];
  programs.virt-manager.enable = true;

  nixpkgs.overlays = [
    (final: previous: {
      mpv = previous.mpv.override {
        scripts = [ final.mpvScripts.mpv-discord ];
      };
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

  programs.niri.enable = true;

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
