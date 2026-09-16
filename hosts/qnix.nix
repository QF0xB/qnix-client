{ lib, pkgs, ... }:
{
  # Client-wide defaults. A host can replace any of these in its own qnix.nix.
  nix.settings = {
    extra-substituters = [
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  qnix.system.users.defaultExtraGroups = lib.mkDefault [
    "audio"
    "video"
    "users"
  ];

  qnix.desktop.client-pr-notify = {
    owner = "QF0xB";
    repo = "qnix-modules";
    matchAuthors = [ "QF0xB" ];
  };

  qnix.security.yubikey = {
    autoLock = false;
    login = true;
    sudo = true;
    u2f.mappings = {
      "q.braendli" = [
        ":WL1eNX3H4cqCpOdlFLskeKHVkf+SUVng34Ch6rxwn5gw+bJrTyH7wBaYE/iY0Rl4Ab0mNJrTtoUqjLaRNvhWbA==,DX5g1dye2T+mX8tNyMg05W3NrbDE527OCWv6BcUgb63H0zEu4BEl9zWlf3tVOINlqyHcS988QVzfzfHKXT5Abw==,es256,+presence"
      ];
    };
  };

  qnix.security.gpg.pinentryPackage = pkgs.pinentry-gnome3;

  qnix.dev.git = {
    userName = "Quirin Brändli";
    userEmail = "qbraendli@pm.me";
  };
}
