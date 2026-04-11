{
  pkgs,
  lib,
  user,
  config,
  ...
}:

{
  networking.hostName = "QPCv2";
  networking.hostId = "5fcc083f"; # Generate with: head -c 8 /etc/machine-id

  system.stateVersion = "24.11";

  services.udev.extraRules = ''
    KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="36b0", ATTRS{idProduct}=="30d8", MODE="0660", TAG+="uaccess", TAG+="udev-acl"
  '';

  # Enable nix-command experimental feature in the VM
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];

      netrc-file = "/etc/nix/garnix-netrc";
      narinfo-cache-positive-ttl = 3600;
    };
  };
}
