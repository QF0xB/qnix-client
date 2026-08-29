{ lib, ... }:
{
  # Client-wide defaults. A host can replace any of these in its own qnix.nix.
  qnix.system.users.defaultExtraGroups = lib.mkDefault [
    "audio"
    "video"
    "users"
  ];
}
