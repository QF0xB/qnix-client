{
  user,
  pkgs,
  inputs,
  ...
}:
{
  qnix = {
    system = {
      boot-manager = {
        encrypted = true;
        loader = "systemd-boot";
        timeout = 3;
      };

      users = {
        defaultExtraGroups = [
          "audio"
          "video"
          "users"
          "plugdev"
        ];

        users.${user} = {
          kind = "normal";
          group = user;
          home = "/home/${user}";
          description = "Quirin Brändli";
          extraGroups = [ "wheel" ];
          passwordFromSops = "up";
        };
      };

      localisation = {
        xkb = {
          layout = "de,de,us";
          variant = "koy, ,";
          console-bridge = true;
        };
      };
    };

    security = {
      gpg = {
        pinentryPackage = pkgs.pinentry-gnome3;
      };

      sops = {
        defaultSopsFile = inputs.self + "/secrets/default.yaml";
        age = {
          keyFile = "/persist/home/${user}/.config/sops/age/keys.txt";
        };
        secrets = {
          up = {
            mode = "0400";
            owner = "root";
            group = "root";
            neededForUsers = true;
          };
          garnix-netrc = {
            key = "garnix/netrc";
            path = "/etc/nix/garnix-netrc";
            mode = "0400";
            owner = "root";
            group = "root";
            restartUnits = [ "nix-daemon.service" ];
          };
        };
      };

      yubikey = {
        autoLock = false;
        login = true;
        u2f.mappings = {
          "q.braendli" = [
            ":WL1eNX3H4cqCpOdlFLskeKHVkf+SUVng34Ch6rxwn5gw+bJrTyH7wBaYE/iY0Rl4Ab0mNJrTtoUqjLaRNvhWbA==,DX5g1dye2T+mX8tNyMg05W3NrbDE527OCWv6BcUgb63H0zEu4BEl9zWlf3tVOINlqyHcS988QVzfzfHKXT5Abw==,es256,+presence"
          ];
        };
      };
    };

    network = {
      networkmanager.extraPlugins = [ "networkmanager-openvpn" ];
    };
  };
}
