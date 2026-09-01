{
  disko,
  home-manager,
  impermanence,
  inputs,
  llm-agents,
  noctalia-shell,
  nixpkgs,
  nixos-hardware,
  nvf,
  qnix,
  system,
  stylix,
}:
let
  hosts = {
    QTestVM = {
      user = "q.braendli";
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
  };

  mkHost =
    hostName: host:
    nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs qnix nixos-hardware; };
      modules = [
        {
          nixpkgs = {
            config.allowUnfree = true;
            overlays = [ llm-agents.overlays.shared-nixpkgs ];
          };
        }
        disko.nixosModules.disko
        impermanence.nixosModules.impermanence
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
            extraSpecialArgs = { inherit inputs qnix; };
            users.${host.user} = {
              imports = qnix.modulesFor.integratedHome host.homeProfiles ++ [
                ./${hostName}/home.nix
              ];
            };
          };
        }
      ]
      ++ qnix.modulesFor.nixos host.nixosProfiles;
    };
in
nixpkgs.lib.mapAttrs mkHost hosts
