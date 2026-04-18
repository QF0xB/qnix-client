{
  lib,
  user,
  pkgs,
  ...
}: {
  xdg.enable = true;
  xdg.desktopEntries.moodle-mobile-poc = {
    name = "Moodle Mobile PoC";
    exec = "${pkgs.python3}/bin/python /persist/home/q.braendli/projects/neuland/moodle-connect/poc.py handle %u";
    terminal = false;
    type = "Application";
    mimeType = ["x-scheme-handler/neuland-next"];
    noDisplay = true;
  };
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "x-scheme-handler/neuland-next" = ["moodle-mobile-poc.desktop"];
    };
  };

  home.username = "q.braendli";
  home.homeDirectory = lib.mkForce "/home/q.braendli";
  home.stateVersion = "24.11";
}
