{ pkgs, ... }:
{
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
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
  ];

  programs.virt-manager.enable = true;

  security.wrappers = {
    ffmpeg = {
      owner = "root";
      group = "root";
      capabilities = "cap_sys_admin+ep";
      source = "${pkgs.ffmpeg}/bin/ffmpeg";
    };
  };

  programs.uwsm.enable = true;

  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
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
