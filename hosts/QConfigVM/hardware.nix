{ lib, pkgs, config, modulesPath, ... }:

let
  # Path to persist.qcow2 - adjust if the file is in a different location
  # This uses an absolute path that should work regardless of where the VM is run from
  persistImagePath = "/home/lcqbraendli/projects/qnix/qnix-client/persist.qcow2";
  
  variantConfig = {
    virtualisation = {
      memorySize = 8192; # 8GB RAM
      cores = 4;
      
      # Forward SSH port
      forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }
      ];
      
      # Use VGA graphics (same as bootloader for consistency)
      graphics = true;
      qemu = {
        options = [
          "-vga" "std"  # Standard VGA (matches bootloader)
          "-display" "sdl"  # SDL display backend (fixes console rendering issues)
          # Use existing persist.qcow2 file as /dev/vdb
          "-drive" "file=${persistImagePath},if=virtio,format=qcow2,index=1"
        ];
      };

      useDefaultFilesystems = true;

      fileSystems."/persist" = {
        device = "/dev/vdb1";
        fsType = "ext4";
        autoFormat = true;
        neededForBoot = true;
      };
    };
  };
in
{

  imports =
  [ (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # QEMU guest services for better VM integration
  services.qemuGuest.enable = true;
  
  # Use VGA console (same as bootloader) for consistent rendering
  boot.kernelParams = [ 
    "console=tty0"  # VGA console (matches bootloader)
    "rd.systemd.show_status=1"
    "systemd.log_level=debug"
  ];

  # VM filesystem configuration for bootloader testing
  virtualisation.vmVariant = variantConfig;
  virtualisation.vmVariantWithBootLoader = variantConfig;
  virtualisation.vmVariantWithDisko = {
    virtualisation = {
      graphics = true;
      qemu = {
        options = [
          "-vga" "std"  # Standard VGA (matches bootloader)
          "-display" "sdl"  # SDL display backend (fixes console rendering issues)
        ];
      };
    };
  };
}


