{ ... }:
{
  # Authentication is provided by the configured YubiKey PAM modules.
  users.allowNoPasswordLogin = true;

  networking = {
    hostName = "QFrame13";
    hostId = "a8b0cd00";
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    narinfo-cache-positive-ttl = 3600;
  };

  system.stateVersion = "26.11";
}
