{ lib, pkgs, ... }:
{
  imports = [
  ];

  services.logind = {
    settings.Login.HandleLidSwitchDocked = "ignore";
    settings.Login.HandleLidSwitch = "ignore";
  };

  programs.steam = {
    enable = true;
  };

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-unwrapped"
    ];
  programs.gamemode.enable = true;

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    bemenu
    kitty
    ffmpeg
    blender
    equibop
    mpv
    yt-dlp
    obs-studio
    firefox
    brightnessctl
    pulsemixer
    vulkan-tools
    xclip
    xhost
  ];

  services.xserver = {
    enable = true;
    desktopManager = {
      xterm.enable = false;
      xfce.enable = true;
    };
    displayManager.lightdm.enable = true;
    displayManager.lightdm.greeter.enable = true;
  };
  services.displayManager.defaultSession = "xfce";

  nixpkgs.overlays = [
    (final: previous: {
      yt-dlp = previous.yt-dlp.override {
        jsRuntime = previous.quickjs-ng;
      };

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
    alsa.support32Bit = true;
    jack.enable = false;
  };

}
