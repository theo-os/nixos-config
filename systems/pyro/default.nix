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

  boot.loader.grub.device = "/dev/vda";
  boot.initrd.availableKernelModules = ["ahci" "xhci_pci" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" "ext4" "btrfs"];

  networking = {
    defaultGateway = {
      address = "45.8.201.1";
      interface = "eth0";
    };
    interfaces = {
      eth0 = {
        ipv4.addresses = [
          {
            address = "45.8.201.20";
            prefixLength = 24;
          }
        ];
      };
    };
  };
}
