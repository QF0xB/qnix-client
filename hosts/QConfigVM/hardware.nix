{ lib, ... }:

{
  # Hardware-specific configuration for QConfigVM
  # VM-specific settings can go here
  
  # VM filesystem configuration for bootloader testing
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 2048; # 2GB RAM
      cores = 2;
      
      # Forward SSH port
      forwardPorts = [
        { from = "host"; host.port = 2222; guest.port = 22; }
      ];
    };

    # Filesystem setup for VM (needed for bootloader)
    # Root filesystem (tmpfs - ephemeral)
    fileSystems."/" = {
      device = "tmpfs";
      fsType = "tmpfs";
      options = [ "size=2G" "mode=755" ];
    };

    # Boot partition (EFI system partition)
    # This is where the bootloader will be installed
    fileSystems."/boot" = {
      device = "/dev/vda1";
      fsType = "vfat";
      # Auto-format on first boot
      autoFormat = true;
      neededForBoot = true;
    };

    # Optional: Persist directory
    fileSystems."/persist" = {
      device = "/dev/vda2";
      fsType = "ext4";
      autoFormat = true;
      neededForBoot = false;
    };
  };
}

