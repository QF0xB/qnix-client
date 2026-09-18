{
  lib,
  ...
}:
{
  home = {
    username = "q.braendli";
    homeDirectory = lib.mkForce "/home/q.braendli";
    stateVersion = "26.11";
  };
}
