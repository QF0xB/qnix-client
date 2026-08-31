{ lib, ... }:
{
  # Client-wide defaults. A host can replace any of these in its own qnix.nix.
  nix.settings = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

  qnix.system.users.defaultExtraGroups = lib.mkDefault [
    "audio"
    "video"
    "users"
  ];
}
