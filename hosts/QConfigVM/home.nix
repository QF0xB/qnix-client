{ lib, user, ... }:

{
  home.username = user;
  home.homeDirectory = lib.mkForce "/home/${user}";
  home.stateVersion = "24.11";
}

