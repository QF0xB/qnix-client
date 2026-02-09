{ lib, user, ... }:

{
  home.username = "q.braendli";
  home.homeDirectory = lib.mkForce "/home/q.braendli";
  home.stateVersion = "24.11";
}

