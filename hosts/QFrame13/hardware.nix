{
  config,
  lib,
  modulesPath,
  nixos-hardware,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    nixos-hardware.nixosModules.framework-amd-ai-300-series
  ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "thunderbolt"
    "nvme"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];
  boot.kernelModules = [
    "kvm-intel"
    # Loaded by the nixos-hardware Framework kmod option disabled below.
    "cros_ec"
    "cros_ec_lpcs"
  ];

  # nixpkgs now merges a signing certificate per external kernel module, but
  # framework-laptop-kmod still installs its module without one, which fails
  # the kernel modules build. This applies the upstream fix,
  # NixOS/nixpkgs#575818. Remove it once that reaches nixos-unstable.
  hardware.framework.enableKmod = false;
  boot.extraModulePackages = [
    (config.boot.kernelPackages.framework-laptop-kmod.overrideAttrs (old: {
      makeFlags =
        old.makeFlags
        ++ [
          "INSTALL_MOD_PATH=${placeholder "out"}"
          "INSTALL_MOD_DIR=extra"
          "DEPMOD=true"
        ];
      installPhase = null;
      installTargets = ["modules_install"];
    }))
  ];

  services.fwupd = {
    enable = true;
    extraRemotes = ["lvfs-testing"];
    uefiCapsuleSettings.DisableCapsuleUpdateOnDisk = true;
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
