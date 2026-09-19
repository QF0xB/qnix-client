{
  config,
  inputs,
  ...
}:
{
  qnix = {
    system.boot = {
      encrypted = true;
      loader = "systemd-boot";
      timeout = 3;
    };

    security.sops = {
      secrets.qframe13-borg-key = {
        sopsFile = inputs.self + "/secrets/qframe13-borg-key.yaml";
        key = "qframe13-borg-key";
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

    backup.borg = {
      enable = true;
      repositories = {
        qnix-eu = "ssh://so3gyqyw@so3gyqyw.repo.borgbase.com/./repo";
        qnix-us = "ssh://t6hcziby@t6hcziby.repo.borgbase.com/./repo";
      };
      sshKeyPath = config.sops.secrets.qframe13-borg-key.path;
      passphrasePaths = {
        qnix-eu = config.sops.secrets.borgbackup-eu-passphrase.path;
        qnix-us = config.sops.secrets.borgbackup-us-passphrase.path;
      };
    };
  };
}
