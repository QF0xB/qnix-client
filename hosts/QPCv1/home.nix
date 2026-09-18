{lib, ...}: {
  home.username = "q.braendli";
  home.homeDirectory = lib.mkForce "/home/q.braendli";
  home.stateVersion = "26.11";
}
