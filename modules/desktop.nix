{pkgs, ...}: {
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    firefox
    alacritty
    fuzzel
    ffmpeg
    blender
    legcord
    zed-editor
    prismlauncher
  ];
  programs.niri.enable = true;
  services.kanata = {
    enable = true;
  };
}
