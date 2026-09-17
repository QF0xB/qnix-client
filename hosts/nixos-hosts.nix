{
  disko,
  home-manager,
  impermanence,
  inputs,
  llm-agents,
  mcp-servers-nix,
  noctalia-shell,
  nixpkgs,
  nixos-hardware,
  nvf,
  sops-nix,
  qnix-modules,
  system,
  stylix,
}:
let
  hosts = {
    QTestVM = {
      user = "q.braendli";
      vm = true;
      nixosProfiles = [
        "developer"
        "hyprland"
        "impermanence"
        "appearance"
      ];
      homeProfiles = [
        "developer"
        "shell"
        "hyprland"
        "appearance"
      ];
    };

    QFrame13 = {
      user = "q.braendli";
      nixosProfiles = [
        "developer"
        "hyprland"
        "impermanence"
        "appearance"
        "laptop"
      ];
      homeProfiles = [
        "developer"
        "shell"
        "hyprland"
        "appearance"
      ];
    };

    QPCv1 = {
      user = "q.braendli";
      nixosProfiles = [
        "developer"
        "hyprland"
        "impermanence"
        "nvidia"
        "appearance"
        "backup"
        "secrets"
        "pentesting"
        "pentest-vms"
      ];
      homeProfiles = [
        "developer"
        "shell"
        "hyprland"
        "appearance"
        "pentesting"
      ];
    };
  };

  mkHost =
    hostName: host:
    let
      hostQnix = qnix-modules.lib.mkQNix {
        context = {
          hostname = hostName;
          inherit mcp-servers-nix;
        }
        // builtins.mapAttrs (_: value: value) (
          builtins.removeAttrs host [
            "user"
            "nixosProfiles"
            "homeProfiles"
          ]
        );
      };
    in
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs nixos-hardware;
        qnix = hostQnix;
      };
      modules = [
        {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [ llm-agents.overlays.shared-nixpkgs ];
          };
        }
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        home-manager.nixosModules.home-manager
        ./${hostName}/configuration.nix
        ./${hostName}/disko.nix
        ./${hostName}/hardware.nix
        ./qnix.nix
        ./${hostName}/qnix.nix
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            sharedModules = [
              nvf.homeManagerModules.default
              noctalia-shell.homeModules.default
            ];
            extraSpecialArgs = {
              inherit inputs;
              qnix = hostQnix;
            };
            users.${host.user} = {
              imports = hostQnix.modulesFor.integratedHome host.homeProfiles ++ [
                ./${hostName}/home.nix
              ];
            };
          };
        }
      ]
      ++ hostQnix.modulesFor.nixos host.nixosProfiles;
    };
in
nixpkgs.lib.mapAttrs mkHost hosts
