{
  inputs,
  config,
  ...
}:
{
  qnix = {
    dev = {
      jetbrains = {
        ideaPro = true;
        rider = true;
        webstorm = true;
        clion = true;
      };
    };
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
          extraGroups = [ "wheel" ];
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
        secrets.github-token = {
          key = "github_token";
          owner = "q.braendli";
          group = "users";
          mode = "0400";
        };
        secrets.qpcv1-borg-key = {
          sopsFile = inputs.self + "/secrets/qpcv1-borg-key.yaml";
          key = "qpcv1-borg-key";
          path = "/persist/home/q.braendli/.ssh/borgbackup";
          owner = "root";
          group = "root";
          mode = "0400";
        };
        secrets.borgbackup-eu-passphrase = {
          key = "borgbackup-eu-passphrase";
          owner = "root";
          group = "root";
          mode = "0400";
        };
        secrets.borgbackup-us-passphrase = {
          key = "borgbackup-us-passphrase";
          owner = "root";
          group = "root";
          mode = "0400";
        };
      };

    };

    backup.borg = {
      enable = true;
      repositories = {
        qnix-eu = "ssh://ctw144ps@ctw144ps.repo.borgbase.com/./repo";
        qnix-us = "ssh://rgxzbo27@rgxzbo27.repo.borgbase.com/./repo";
      };
      sshKeyPath = config.sops.secrets.qpcv1-borg-key.path;
      passphrasePaths = {
        qnix-eu = config.sops.secrets.borgbackup-eu-passphrase.path;
        qnix-us = config.sops.secrets.borgbackup-us-passphrase.path;
      };
    };

    pentest.vms = {
      managerUsers = [ "q.braendli" ];
      machines = {
        QPenT = {
          installerIso = "/cache/home/q.braendli/Downloads/kali-linux-2026.2-installer-everything-amd64.iso";
          memoryMiB = 16384;
          vcpus = 8;
          network.mode = "isolated-nat";
        };
        QPenL = {
          installerIso = "/cache/home/q.braendli/Downloads/kali-linux-2026.2-installer-everything-amd64.iso";
          memoryMiB = 12288;
          vcpus = 6;
          network.mode = "isolated-nat";
        };
        QPenA = {
          installerIso = "/cache/home/q.braendli/Downloads/kali-linux-2026.2-installer-everything-amd64.iso";
          memoryMiB = 16384;
          vcpus = 8;
          network.mode = "air-gapped";
        };
        QPenP = {
          installerIso = "/cache/home/q.braendli/Downloads/kali-linux-2026.2-installer-everything-amd64.iso";
          memoryMiB = 16384;
          vcpus = 8;
          network.mode = "isolated-nat";
        };
      };
    };

    dev.git.githubTokenPath = config.sops.secrets.github-token.path;
  };
}
