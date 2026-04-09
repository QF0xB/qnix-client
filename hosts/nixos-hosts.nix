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
        "creator"
        "hyprland"
        "personal"
        "stylix"
        "impermanence"
      ];

  defaultHomeProfiles =
    if specialArgs ? defaultHomeProfiles then
      specialArgs.defaultHomeProfiles
    else
      [
        "creator"
        "hyprland"
        "personal"
        "stylix"
      ];

  hosts = {
    QConfigVM = {
      user = defaultUser;
      nixosProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
        "impermanence"
      ];
      homeProfiles = [
        "creator"
        "hyprland"
        "laptop"
        "personal"
        "stylix"
      ];
    };

    QTestVM = {
      user = defaultUser;
      nixosProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
        "impermanence"
        "dev"
      ];
      homeProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
        "dev"
      ];
    };

    QFrame13 = {
      user = defaultUser;
      nixosProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
        "laptop"
      ];
      homeProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
      ];
    };

    QPCv1 = {
      user = defaultUser;
      nixosProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
      ];
      homeProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
      ];
    };

    QPCv2 = {
      user = defaultUser;
      nixosProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
      ];
      homeProfiles = [
        "creator"
        "hyprland"
        "personal"
        "stylix"
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
        inputs.stylix.nixosModules.stylix
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
            sharedModules = [
              inputs.noctalia-shell.homeModules.default
            ];
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
