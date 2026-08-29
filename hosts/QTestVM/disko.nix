{
  ...
}:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/vda";
      imageSize = "20G";

      content = {
        type = "gpt";
        partitions = {
          ESP = {
            size = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          zfs = {
            size = "100%";
            type = "8309";
            content = {
              type = "zfs";
              pool = "zroot";
            };
          };
        };
      };
    };

    zpool.zroot = {
      type = "zpool";
      options = {
        ashift = "12";
        autotrim = "on";
        cachefile = "none";
      };
      rootFsOptions = {
        compression = "zstd";
        acltype = "posixacl";
        atime = "off";
        xattr = "sa";
        normalization = "formD";
        mountpoint = "none";
      };
      datasets = {
        root = {
          type = "zfs_fs";
          mountpoint = "/";
        };
        persist = {
          type = "zfs_fs";
          mountpoint = "/persist";
        };
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        cache = {
          type = "zfs_fs";
          mountpoint = "/cache";
        };
      };
    };
  };
}
