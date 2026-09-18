{...}: {
  networking = {
    hostName = "QPCv1";
    hostId = "92f2ed5a";
  };

  # Enable nix-command experimental feature in the VM
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    narinfo-cache-positive-ttl = 3600;
  };

  system.stateVersion = "26.11";
}
