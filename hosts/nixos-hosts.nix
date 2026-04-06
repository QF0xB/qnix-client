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
        "base"
        "workstation"
        "impermanence"
      ];

  defaultHomeProfiles =
    if specialArgs ? defaultHomeProfiles then
      specialArgs.defaultHomeProfiles
    else
      [
        "base"
        "workstation"
      ];

  hosts = {
    QConfigVM = {
      user = defaultUser;
      nixosProfiles = [
        "base"
        "workstation"
        "impermanence"
      ];
      homeProfiles = [
        "base"
        "workstation"
      ];
    };

    QTestVM = {
      user = defaultUser;
      nixosProfiles = [
        "base"
        "workstation"
        "impermanence"
      ];
      homeProfiles = [
        "base"
        "workstation"
      ];
    };

    QFrame13 = {
      user = defaultUser;
      nixosProfiles = [
        "base"
        "workstation"
        "laptop"
      ];
      homeProfiles = [
        "base"
        "workstation"
      ];
    };

    QPCv1 = {
      user = defaultUser;
      nixosProfiles = [
        "base"
        "workstation"
      ];
      homeProfiles = [
        "base"
        "workstation"
      ];
    };

    QPCv2 = {
      user = defaultUser;
      nixosProfiles = [
        "base"
        "workstation"
      ];
      homeProfiles = [
        "base"
        "workstation"
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
        dots = "/persist/home/${user}/projects/qnix/client";
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
          nix.settings.trusted-users = [ user ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = extraArgs;

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
