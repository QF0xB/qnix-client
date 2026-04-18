{
  user,
  pkgs,
  inputs,
  ...
}:
{
  qnix = {
    desktop = {
      hyprland = {
        noHardwareCursors = true;
      };
    };
    system = {
      bluetooth.enable = true;

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
          github_token = {
            key = "github_token";
            mode = "0400";
            owner = "${user}";
            group = "${user}";
          };
          borgbackup-eu-passphrase = {
            key = "borgbackup-eu-passphrase";
            mode = "0400";
            owner = "root";
            group = "root";
          };
          borgbackup-us-passphrase = {
            key = "borgbackup-us-passphrase";
            mode = "0400";
            owner = "root";
            group = "root";
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

    storage.backup = {
      enable = true;

      targets.borg = {
        eu = {
          enable = true;
          repo = "ssh://t9zp3694@t9zp3694.repo.borgbase.com/./repo";
          sshKeyPath = "/persist/home/${user}/.ssh/qpcv2-backup";
          sshKnownHostsFile = "/persist/home/${user}/.ssh/known_hosts";
          encryption.sopsSecretName = "borgbackup-eu-passphrase";
        };

        us = {
          enable = true;
          repo = "ssh://e7yq45o0@e7yq45o0.repo.borgbase.com/./repo";
          sshKeyPath = "/persist/home/${user}/.ssh/qpcv2-backup";
          sshKnownHostsFile = "/persist/home/${user}/.ssh/known_hosts";
          encryption.sopsSecretName = "borgbackup-us-passphrase";
        };
      };
    };
  };
}
