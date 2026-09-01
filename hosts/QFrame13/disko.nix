{ lib, ... }:
{
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme0n1";
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
          swap = {
            size = "8G";
            type = "8200";
            content.type = "swap";
          };
          root = {
            size = "100%";
            type = "8309";
            content = {
              type = "luks";
              name = "cryptroot";
              passwordFile = "/tmp/luks-password";
              settings.allowDiscards = true;
              content = {
                type = "zfs";
                pool = "zroot";
              };
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
      };
      rootFsOptions = {
        compression = "zstd";
        acltype = "posixacl";
        atime = "off";
        xattr = "sa";
        normalization = "formD";
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
