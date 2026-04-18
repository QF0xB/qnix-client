{
  inputs,
  pkgs,
  lib,
  qnixLib,
  specialArgs ? {},
  ...
}: let
  defaultUser =
    if specialArgs ? defaultUser
    then specialArgs.defaultUser
    else "q.braendli";

  defaultProfiles = [
    "dev"
    "hyprland"
    "nvf"
    "personal"
    "stylix"
  ];

  applyProfileOverrides = defaultProfiles': hostDef: let
    baseProfiles = hostDef.profiles or defaultProfiles';
    extraProfiles = (hostDef.extra or {}).profiles or [];
    disabledProfiles = (hostDef.disable or {}).profiles or [];
    mergedProfiles = lib.unique (baseProfiles ++ extraProfiles);
  in
    builtins.filter (profile: !(builtins.elem profile disabledProfiles)) mergedProfiles;

  hosts = {
    QTestVM = {
      user = defaultUser;
      extra.profiles = [
        "laptop"
      ];
    };

    QFrame13 = {
      user = defaultUser;
      extra.profiles = [
        "laptop"
        "impermanence"
      ];
    };

    QPCv1 = {
      user = defaultUser;
      extra.profiles = ["impermanence"];
    };

    QPCv2 = {
      user = defaultUser;
      extra.profiles = ["impermanence"];
    };
  };

  mkHost = hostName: hostDef: let
    user = hostDef.user or defaultUser;
    profiles = applyProfileOverrides defaultProfiles hostDef;
    hostPath = ./. + "/${hostName}";
    extraArgs = {
      inherit
        inputs
        qnixLib
        hostName
        user
        profiles
        ;
    };
  in
    lib.nixosSystem {
      inherit pkgs lib;

      specialArgs = extraArgs;

      modules =
        [
          inputs.stylix.nixosModules.stylix
          "${hostPath}/configuration.nix"
          "${hostPath}/qnix.nix"
          "${hostPath}/hardware.nix"

          inputs.impermanence.nixosModules.impermanence
          inputs.sops-nix.nixosModules.sops
          inputs.disko.nixosModules.disko

          (import "${inputs.qnix-modules}/loader/nixos.nix" {
            inherit lib;
            inherit profiles;
          })

          inputs.home-manager.nixosModules.home-manager
          {
            qnix.system.shell.projectRoot = "/persist/home/${user}/projects/qnix/client";

            nix.settings.trusted-users = [user];

            home-manager = {
              useGlobalPkgs = true;
              backupFileExtension = "bak";

              useUserPackages = true;
              sharedModules = [
                inputs.nvf.homeManagerModules.default
                inputs.noctalia-shell.homeModules.default
              ];
              extraSpecialArgs =
                extraArgs
                // {
                  qnixHomeStandalone = false;
                };

              users.${user} = {
                imports = [
                  (import "${inputs.qnix-modules}/loader/home.nix" {
                    lib = inputs.nixpkgs.lib;
                    inherit profiles;
                  })
                  "${hostPath}/home.nix"
                ];
              };
            };
          }

          (lib.mkAliasOptionModule ["hm"] ["home-manager" "users" user])
        ]
        ++ lib.optional (builtins.pathExists "${hostPath}/disko.nix") "${hostPath}/disko.nix";
    };
in
  lib.mapAttrs mkHost hosts
