{
  pkgs,
  lib,
  user,
  config,
  ...
}:

{
  networking.hostName = "QPCv1";
  networking.hostId = "92f2ed5a";

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
