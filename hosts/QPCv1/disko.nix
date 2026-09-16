{
  lib,
  pkgs ? null,
  ...
}: let
  isImageBuild = builtins.getEnv "IS_IMAGE_BUILD" == "1";

  # This is a placeholder for the LUKS password file that is created during the image build
  imageLuksPasswordFile =
    if isImageBuild
    then pkgs.writeText "luks-password" "changeme"
    else null;
in {
  disko.devices = {
    disk.main = {
      type = "disk";
      device = "/dev/nvme1n1";
      imageSize = "10G";

      content = {
        type = "gpt";
        partitions =
          {
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["umask=0077"];
              };
            };
          }
          // lib.optionalAttrs (!isImageBuild) {
            swap = {
              size = "8G";
              type = "8200";
              content = {
                type = "swap";
              };
            };
          }
          // {
            root = {
              size = "100%";
              type = "8309"; # LUKS encrypted ZFS partition

              content = {
                type = "luks";
                name = "cryptroot"; # /dev/mapper/cryptroot
                passwordFile =
                  if isImageBuild
                  then "${imageLuksPasswordFile}"
                  else "/tmp/luks-password"; # Only used during installation
                settings =
                  lib.optionalAttrs isImageBuild {
                    keyFile = "${imageLuksPasswordFile}";
                  }
                  // {
                    allowDiscards = true;
                  };
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

      # “Ephemeral /” via rollback: keep / as its own dataset
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
