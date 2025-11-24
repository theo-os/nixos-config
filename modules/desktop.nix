{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.oxwm.nixosModules.default
  ];

  services.xserver = {
    enable = true;
    windowManager.oxwm = {
      enable = true;
    };
  };

  hardware.graphics.enable = true;
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  environment.systemPackages = with pkgs; [
    firefox
    rio
    bemenu
    xclip
    maim
    ffmpeg
    blender
    legcord
    zed-editor
    prismlauncher
    xorg.xinit
  ];
  services.kanata = {
    enable = true;
  };
}
