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

  system.stateVersion = "25.11";

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
