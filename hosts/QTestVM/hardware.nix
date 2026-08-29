{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 12288;
      cores = 8;
      graphics = true;
      useDefaultFilesystems = true;
    };
  };
}
