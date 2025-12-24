{ inputs, pkgs, ... }:
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  hardware.graphics = {
    enable = true;
    package =
      (pkgs.mesa.overrideAttrs (old: {
        version = inputs.mesa.rev;
        src = inputs.mesa;
      })).override
        {
          galliumDrivers = [
            "zink"
            "virgl"
          ];
        };
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };
  environment.systemPackages = with pkgs; [
    firefox
    alacritty
    hyprshot
    wl-clipboard
    bemenu
    ffmpeg
    obs-studio
    blender
    equibop
    prismlauncher
    opencode
    zed-editor
    lmms
    android-studio
    mpv
    yt-dlp
    mullvad-vpn
    mangohud
    chromium
    xwayland-satellite
    brightnessctl
  ];
  nixpkgs.config.allowUnfree = true;

  services.mullvad-vpn.enable = true;

  security.wrappers = {
    ffmpeg = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.ffmpeg}/bin/ffmpeg";
    };
  };

  programs.niri = {
    enable = true;
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
