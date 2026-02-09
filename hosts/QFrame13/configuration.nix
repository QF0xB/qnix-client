{
  pkgs,
  lib,
  user,
  config,
  ...
}:

{
  networking.hostName = "QFrame13";
  networking.hostId = "a8b0cd00"; # Generate with: head -c 8 /etc/machine-id

  system.stateVersion = "24.11";

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
