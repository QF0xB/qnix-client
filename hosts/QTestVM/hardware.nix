{ modulesPath, pkgs, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules = [
    "ahci"
    "xhci_pci"
    "virtio_pci"
    "virtio_blk"
    "virtio_gpu"
  ];
  boot.kernelModules = [ "kvm-intel" ];

  hardware.graphics.enable = true;

  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;

  virtualisation.vmVariant = {
    virtualisation = {
      memorySize = 16384;
      cores = 12;
      graphics = true;
      useDefaultFilesystems = true;

      qemu = {
        package = pkgs.qemu_full;
        forceAccel = true;
        options = [
          "-vga none"
          "-device virtio-vga-gl"
          "-display sdl,gl=on,show-cursor=off"
        ];
      };
    };
  };
}
