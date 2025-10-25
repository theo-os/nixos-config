{pkgs}: {
  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    firefox
    alacritty
    ffmpeg
    blender
    legcord
  ];
  services.kanata = {
    enable = true;
  };
}
