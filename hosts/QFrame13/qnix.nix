{ user, pkgs, ... }:
{
  # QNix module options for QConfigVM
  qnix = {
    development = true;
    headless = false;
    server = false;
    work = false;

    core = {
      boot = {
        encrypted = true;

        grub = {
          enable = false;
        };

        "systemd-boot" = {
          enable = true;
        };

        timeout = 3;
      };

      fail2ban = {
        enable = false;
      };

      git = {
        enable = true;
        lfs = true;
        signing = true;
        signingKey = "90360B7DB6B78B75E9013D113FF8C23C46F2CC90";
        userName = "Quirin Brändli";
        userEmail = "qbraendli@pm.me";
      };

      gpg = {
        enable = true;
        pinentryPackage = pkgs.pinentry-gnome3;
        publicKeys = [
          {
            url = "https://keys.openpgp.org/vks/v1/by-fingerprint/90360B7DB6B78B75E9013D113FF8C23C46F2CC90";
            sha256 = "sha256-q03XOg1DYUMjF/8r3vJ8OHTcNPJdsNnXNf/ODWiL3vg=";
            trust = "ultimate";
          }
        ];
      };

      impermanence = {
        enable = true;
      };

      localisation = {
        enable = true;

        timezone = "Europe/Berlin";
        xkb = {
          layout = "de,de,us";
          variant = "koy, ,";
          console-bridge = true;
        };
      };

      lsd = {
        enable = true;
      };

      network = {
        firewall = {
          enable = false;
        };

        nm = {
          enable = true;
          extraPlugins = [
            "networkmanager-openvpn"
          ];
          gui = true;
        };
      };

      nvf = {
        enable = true;
      };

      passwords = {
        bitwarden = {
          cli = {
            enable = false;
          };
          desktop = {
            enable = true;
          };
        };
      };

      plymouth = {
        enable = true;
      };

      polkit = {
        enable = true;
      };

      shell = {
        enable = true;

        fish = {
          enable = true;
        };
      };

      sops = {
        enable = true;
        defaultSopsFile = ../../secrets/default.yaml;

        age = {
          generateKey = false;
          keyFile = "/persist/home/${user}/.config/sops/age/keys.txt";
        };

        secrets = {
          "up" = {
            mode = "0400";
            owner = "root";
            group = "root";
            neededForUsers = true;
          };
          "rp" = {
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

            # wantedBy = [ "nix-daemon.service" ];
            restartUnits = [ "nix-daemon.service" ];
          };
        };
      };

      ssh-server = {
        enable = false;
      };

      starship = {
        enable = true;
      };

      stylix = {
        enable = true;

        wallpapers = {
          enable = true;
        };
      };

      user = {
        enable = true;

        defaultExtraGroups = [
          "audio"
          "video"
          "users"
          "plugdev"
        ];

        root = {
          enable = true;
          password = "$y$j9T$ZbVZ.p8xaCWvL.ULkJHAH1$4hwPBaX7Thcj41eFvpB2KfWVn0nKpCyalpkIigG6yc1";
        };

        users = {
          "q.braendli" = {
            isNormalUser = true;
            group = "q.braendli";
            home = "/home/q.braendli";
            description = "Quirin Brändli";
            extraGroups = [ "wheel" ];
            initialHashedPassword = "$y$j9T$ZbVZ.p8xaCWvL.ULkJHAH1$4hwPBaX7Thcj41eFvpB2KfWVn0nKpCyalpkIigG6yc1";
            openssh.authorizedKeys.keys = [
              "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDk4DIfOYj5u7Gy01r5eVUuJzaniD8N1pJqOmxtgWRaiMlS+v5Za/Xu2vRpMNoO2lb8nr/FNev4p1wuzNEQjJoEcLTM0JMbUs+4AakUbdOq2P9rAH4A7rNP24fcVtAjSGp/g9krWA3J/WxttNJ0HGfNuSCX871gy6K36KF7l3Jpnfz6h+RwwNsvxTiP/a8S2WFuzr3Wt49px7k4usyQBQoBsOR9EkeqvERsWkBFOltDlqi6GbLTFmaV7B1LQPlAyBOnzvJ0Jp/IM4eyzR6Bc6pVoWxUH619GBifL85qCTGgPDMVnljxRDd0gt8bIueF41lEM/1arJQNH8XdUIF/mX7u7hNYw7MVPmkkwbLy2NUjh0/5RzU8hdE3J9aLRT/EwjZF/0ratIRvjNvGohm0U84jjraCmfZqezgaL3E9DCgXabgDAex9lVlDG/N6b07J0MJ8w2enbOI344iHv2ZpcODoi2ZB674mBDNsarmIUsi2vacCN8/pogirNFDNrU5jEF2lVHrJjNka0sTPlhrk1EoiT1dOcd9X3+STM7SEcY5R8YARCxBD3q3RG1u6f1akFN+QyvEUiV+hVtfrKnTwl2ldZ7Dmlbj7ghhudQQrRNGQ5PvjhNbTLtk+l4sfRbDiiVA0BU9AZiqZq0PeVXErJft2TTPP8UKGN35qGly4YHzfhw== cardno:25_390_975"
            ];
            passwordFromSops = "up";
          };
        };
      };

      virtualisation = {
        virt-manager = {
          enable = false;
          gui = true;
          passthrough = false;
        };
      };

      yubikey = {
        enable = true;
        autolock = false;
        login = true;
      };

      zfs = {
        enable = true;

        scrub = {
          enable = true;
        };
      };
    };

    desktop = {
      browser = {
        enable = true;
        brave = {
          enable = true;
        };
        firefox = {
          enable = true;
        };
      };

      displaymanager = {
        enable = true;

        sddm = {
          enable = true;
        };
      };

      hyprdesktop = {
        enable = true;

        ags = {
          enable = false;
        };

        hyprsuite = {
          hyprland = {
            enable = true;
          };
        };

        noctalia = {
          enable = true;
        };
      };

      jetbrains = {
        enable = true;

        idea.enable = true;
      };

      laptop-specifics = {
        enable = true;
      };

      obsidian = {
        enable = true;
      };

      periphery = {
        thunderbolt = {
          enable = true;
        };
      };

      sound = {
        enable = true;
      };

      terminal = {
        enable = true;
      };

      tidal-hifi = {
        enable = true;
      };

      vscode = {
        enable = true;

        package = pkgs.code-cursor;
        agentPanelSize = 100;
      };

      xdg-folders = {
        enable = true;
      };
    };
  };
}
