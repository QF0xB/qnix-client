{ lib, ... }:
{
  qnix = {
    system = {
      boot = {
        encrypted = true;
        loader = "systemd-boot";
        timeout = 3;
      };

      };

    };
}
