{
  pkgs,
  lib,
  user,
  config,
  ...
}:

{
  networking.hostName = "QTestVM";
  networking.hostId = "01234567"; # Generate with: head -c 8 /etc/machine-id

  services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="30d8", MODE="0660",
    TAG+="uaccess", TAG+="udev-acl"
  '';

  system.stateVersion = "26.05";

  # Enable nix-command experimental feature in the VM
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
}
