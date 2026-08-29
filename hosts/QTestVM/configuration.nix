{
  config,
  lib,
  pkgs,
  ...
}:
{
  networking = {
    hostName = "QTestVM";
    hostId = "01234567";
  };

  boot.zfs = {
    devNodes = "/dev/disk/by-id";
    forceImportRoot = true;
  };

  # Create the rollback target as part of the Disko image/install flow. The
  # root dataset is empty at this point; /persist, /cache and /nix are separate
  # datasets and therefore survive subsequent root rollbacks.
  system.build.destroyFormatMount = lib.mkIf (config.disko.testMode or false) (
    let
      baseDestroyFormatMount =
        (config.disko.devices._scripts {
          inherit pkgs;
          checked = config.disko.checkScripts;
        }).destroyFormatMount;
    in
    lib.mkForce (
      pkgs.writeShellScriptBin "destroy-format-mount-with-blank" ''
        set -euo pipefail
        ${lib.getExe baseDestroyFormatMount} "$@"

        if ! ${config.boot.zfs.package}/bin/zfs list -H -t snapshot zroot/root@blank >/dev/null 2>&1; then
          ${config.boot.zfs.package}/bin/zfs snapshot zroot/root@blank
        fi
      ''
    )
  );

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.11";
}
