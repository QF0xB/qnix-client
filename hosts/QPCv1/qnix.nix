{lib, ...}: {
  qnix = {
    system = {
      boot = {
        encrypted = true;
        loader = "systemd-boot";
        timeout = 3;
      };

      localisation.xkb = {
        layout = "de,de,us";
        variant = "koy,,";
      };

      users = {
        defaultExtraGroups = [
          "audio"
          "video"
          "users"
          "plugdev"
        ];
        users."q.braendli" = {
          home = "/home/q.braendli";
          description = "Quirin Brändli";
          extraGroups = ["wheel"];
        };
      };
    };
  };
}
