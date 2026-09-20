{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Stable by-id path rather than /dev/nvme0n1 — this is the device
        # disko DESTROYS at install time, and kernel names like /dev/sda can
        # shift between boots when more than one disk is present. The running
        # system doesn't use this path (filesystems are mounted by
        # partlabel), so it only matters during install — which is exactly
        # when getting it wrong is unrecoverable.
        device = "/dev/disk/by-id/nvme-KXG6AZNV256G_TOSHIBA_81MC10D4E1J4";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "8G";
              # Random key each boot: good for privacy, but makes hibernation
              # impossible. Drop randomEncryption if you want suspend-to-disk.
              content = { type = "swap"; randomEncryption = true; };
            };
            root = {
              size = "100%";
              content = { type = "filesystem"; format = "ext4"; mountpoint = "/"; };
            };
          };
        };
      };
    };
  };
}
