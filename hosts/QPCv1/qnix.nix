{
  inputs,
  ...
}: {
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
          passwordFromSops = "up";
          extraGroups = ["wheel"];
        };
      };
    };

    security = {
      sops = {
        defaultSopsFile = inputs.self + "/secrets/default.yaml";
        age.keyFile = "/persist/home/q.braendli/.config/sops/age/keys.txt";
        secrets.up = {
          mode = "0400";
          owner = "root";
          group = "root";
          neededForUsers = true;
        };
      };

    };
  };
}
