{
  inputs,
  pkgs,
  lib,
  qnixLib,
  specialArgs ? { },
  ...
}:
let
  defaultUser = if specialArgs ? defaultUser then specialArgs.defaultUser else "q.braendli";

  defaultNixosProfiles =
    if specialArgs ? defaultNixosProfiles then
      specialArgs.defaultNixosProfiles
    else
      [
        "hyprland"
        "impermanence"
      ];

  defaultHomeProfiles =
    if specialArgs ? defaultHomeProfiles then
      specialArgs.defaultHomeProfiles
    else
      [
        "hyprland"
      ];

  hosts = {
    QConfigVM = {
      user = defaultUser;
      nixosProfiles = [
        "hyprland"
        "impermanence"
      ];
      homeProfiles = [
        "hyprland"
      ];
    };

    QTestVM = {
      user = defaultUser;
      nixosProfiles = [
        "hyprland"
        "impermanence"
        "dev"
      ];
      homeProfiles = [
        "hyprland"
        "dev"
      ];
    };

    QFrame13 = {
      user = defaultUser;
      nixosProfiles = [
        "hyprland"
        "laptop"
      ];
      homeProfiles = [
        "hyprland"
      ];
    };

    QPCv1 = {
      user = defaultUser;
      nixosProfiles = [
        "hyprland"
      ];
      homeProfiles = [
        "hyprland"
      ];
    };

    QPCv2 = {
      user = defaultUser;
      nixosProfiles = [
        "hyprland"
      ];
      homeProfiles = [
        "hyprland"
      ];
    };
  };

  mkHost =
    hostName: hostDef:
    let
      user = hostDef.user or defaultUser;
      nixosProfiles = hostDef.nixosProfiles or defaultNixosProfiles;
      homeProfiles = hostDef.homeProfiles or defaultHomeProfiles;
      hostPath = ./. + "/${hostName}";
      extraArgs = {
        inherit
          inputs
          qnixLib
          hostName
          user
          nixosProfiles
          homeProfiles
          ;
      };
    in
    lib.nixosSystem {
      inherit pkgs lib;

      specialArgs = extraArgs;

      modules = [
        "${hostPath}/configuration.nix"
        "${hostPath}/qnix.nix"
        "${hostPath}/hardware.nix"

        inputs.impermanence.nixosModules.impermanence
        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko

        (import "${inputs.qnix-modules}/loader/nixos.nix" {
          inherit lib;
          profiles = nixosProfiles;
        })

        inputs.home-manager.nixosModules.home-manager
        {
          qnix.system.shell.projectRoot = "/persist/home/${user}/projects/qnix/client";

          nix.settings.trusted-users = [ user ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = extraArgs // {
              qnixHomeStandalone = false;
            };

            users.${user} = {
              imports = [
                (import "${inputs.qnix-modules}/loader/home.nix" {
                  lib = inputs.nixpkgs.lib;
                  profiles = homeProfiles;
                })
                "${hostPath}/home.nix"
              ];
            };
          };
        }

        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])
      ]
      ++ lib.optional (builtins.pathExists "${hostPath}/disko.nix") "${hostPath}/disko.nix";
    };
in
lib.mapAttrs mkHost hosts
