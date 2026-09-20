{
  inputs,
  lib,
  pkgs,
  config,
  ...
}: {
  # Client-wide defaults. A host can replace any of these in its own qnix.nix.
  nix.settings = {
    extra-substituters = [
      "https://cache.flakehub.com"
      "https://cache.numtide.com"
      "https://nix-community.cachix.org"
      "https://cache.nix-ci.com"
    ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "nix-ci:g3xV5BDTLtIBZr/A00IU1x0EtKKlb7YLgBN2SgYgM6A="
    ];
  };

  # The encrypted secret contains root-only netrc entries for authenticated caches.
  nix.extraOptions = "netrc-file = ${config.sops.secrets.flakehub-cache.path}";

  qnix.system.users.defaultExtraGroups = lib.mkDefault [
    "audio"
    "video"
    "users"
    "plugdev"
  ];

  qnix.system.localisation.xkb = {
    layout = "de,de,us";
    variant = "koy,,";
  };

  qnix.system.users.users."q.braendli" = {
    home = "/home/q.braendli";
    description = "Quirin Brändli";
    extraGroups = [ "wheel" ];
  };

  qnix.security.sops = {
    defaultSopsFile = inputs.self + "/secrets/default.yaml";
    age.keyFile = "/persist/home/q.braendli/.config/sops/age/keys.txt";
    secrets.up = {
      mode = "0400";
      owner = "root";
      group = "root";
      neededForUsers = true;
    };
    secrets.github-token = {
      key = "github_token";
      owner = "q.braendli";
      group = "users";
      mode = "0400";
    };
    secrets.flakehub-cache = {
      owner = "root";
      group = "root";
      mode = "0400";
    };
  };

  qnix.dev.git.githubTokenPath = config.sops.secrets.github-token.path;

  qnix.desktop.client-pr-notify = {
    owner = "QF0xB";
    repo = "qnix-client";
    titleContains = "chore(flake): flake lock update";
    githubTokenPath = config.sops.secrets.github-token.path;
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
