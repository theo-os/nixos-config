{...}: {
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["compress=zstd:9" "noatime"];
  };
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "ext4";
  };

  boot.loader.grub.device = "/dev/sda";
  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" "btrfs"];

  networking = {
    defaultGateway = {
      address = "46.62.228.117";
      interface = "eth0";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eth0";
    };
    interfaces = {
      eth0 = {
        ipv6.addresses = [
          {
            address = "2a01:4f9:c013:a635::69";
            prefixLength = 64;
          }
        ];
        ipv4.addresses = [
          {
            address = "46.62.228.117";
            prefixLength = 24;
          }
        ];
      };
    };
  };
}
