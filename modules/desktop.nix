{ inputs, pkgs, ... }:
let
  chromiumFlags = "--use-cmd-decoder=passthrough --enable-features=WaylandLinuxDrmSyncobj,AcceleratedVideoDecodeLinuxZeroCopyGL,AcceleratedVideoDecodeLinuxGL,VaapiOnNvidiaGPUs,AcceleratedVideoEncoder --enable-unsafe-webgpu";
in
{
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
  hardware.graphics = {
    enable = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
  };

  nixpkgs.overlays = [
    (final: previous: {
      chromium = previous.chromium.override {
        commandLineArgs = chromiumFlags;
      };
    })
  ];

  environment.systemPackages = with pkgs; [
    firefox
    alacritty
    hyprshot
    wl-clipboard
    bemenu
    ffmpeg
    obs-studio
    blender
    prismlauncher
    opencode
    neovide
    lmms
    android-studio
    mpv
    yt-dlp
    mullvad-vpn
    mangohud
    xwayland-satellite
    brightnessctl
    chromium
    equibop
    inputs.awww.packages.${pkgs.stdenv.hostPlatform.system}.awww
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
