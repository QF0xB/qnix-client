{...}: {
  networking = {
    hostName = "QPCv2";
    hostId = "5fcc083f";
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
