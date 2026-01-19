{
  lib,
  pkgs,
  config,
  modulesPath,
  ...
}:

{

  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "sr_mod"
    "virtio_blk"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # QEMU guest services for better VM integration
  services.qemuGuest.enable = true;

  # Use VGA console (same as bootloader) for consistent rendering
  boot.kernelParams = [
    "console=tty0" # VGA console (matches bootloader)
    "rd.systemd.show_status=1"
    "systemd.log_level=debug"
  ];
}
