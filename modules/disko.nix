{
  disks ? [ "/dev/sda" ],
  ...
}:
{
  disko.devices = {
    disk = {
      sda = {
        device = builtins.elemAt disks 0;
        type = "disk";
        content = {
          type = "table";
          format = "gpt";
          partitions = [
            {
              name = "ESP";
              start = "1MiB";
              end = "4GiB";
              bootable = true;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            }
            {
              name = "root";
              start = "4GiB";
              end = "100%";
              part-type = "primary";
              content = {
                type = "filesystem";
                format = "bcachefs";
                mountpoint = "/";
              };
            }
          ];
        };
      };
    };
  };
}
