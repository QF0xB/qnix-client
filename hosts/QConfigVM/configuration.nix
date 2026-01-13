{
  pkgs,
  lib,
  user,
  ...
}:

{
  networking.hostName = "QConfigVM";
  networking.hostId = "01234567"; # Generate with: head -c 8 /etc/machine-id

  system.stateVersion = "24.11";

  # Enable nix-command experimental feature in the VM
  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };

  
  environment.systemPackages = with pkgs; [
    lunarvim
  ];

  # Enable SSH for VM access (better than buggy console)
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "yes"; # For VM testing
      PasswordAuthentication = true;
    };
  };
}
