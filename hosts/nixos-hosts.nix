{
  inputs,
  pkgs,
  lib,
  specialArgs,
  ...
}@args:
let
  mkNixosConfiguration =
    host:
    {
      pkgs ? args.pkgs,
      user ? "q.braendli",
      isVm ? false,
      isInstall ? false,
      isLaptop ? false,
      isNixOS ? true,
      loadOptions ? false,
      extraConfig ? { },
    }:
    lib.nixosSystem {
      inherit pkgs;

      specialArgs = specialArgs // {
        # Full inputs needed for imports (inputs.qnix-modules, etc.)
        inherit inputs;
        # categories and filtered inputs are already in specialArgs from flake.nix
        inherit
          host
          isVm
          isInstall
          isLaptop
          isNixOS
          user
          loadOptions
          ;
        dots = "/persist/home/${user}/projects/qnix/qnix-client";
      };

      modules = [
        # Host-specific configuration
        # ./${host}/qnix.nix
        ./${host}/configuration.nix
        ./${host}/hardware.nix

        # Load QNix modules (will use categories from specialArgs)
        inputs.qnix-modules.nixosModules.qnix

        {
          environment.systemPackages = [ pkgs.fh ];
        }

        # Home Manager
        inputs.home-manager.nixosModules.home-manager

        {
          nix.settings.trusted-users = [ user ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = specialArgs // {
              # Full inputs needed for imports
              inherit inputs;
              # categories and filtered inputs are already in specialArgs from flake.nix
              inherit 
                host
                isVm
                isInstall
                isLaptop
                isNixOS
                user
                loadOptions
                ;
              dots = "/persist/home/${user}/projects/qnix/qnix-client";
            };

            users.${user} = {
              imports = [
                inputs.qnix-modules.homeManagerModules.qnix
                # Load QNix Home Manager modules (will use categories from specialArgs)
                ./${host}/home.nix
                ./${host}/qnix.nix  # qnix.* options for this host
                
                # Direct imports for modules that need it (if not handled by qnix-modules)
                inputs.ags.homeManagerModules.default
              ];
            };
          };
        }

        # Other modules
        inputs.impermanence.nixosModules.impermanence
        inputs.disko.nixosModules.disko

        # Import host-specific disko configuration if it exists

        inputs.sops-nix.nixosModules.sops
        inputs.qnix-pkgs.nixosModules.default

        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])

        extraConfig
      ]
      ++ lib.optional (builtins.pathExists ./${host}/disko.nix) ./${host}/disko.nix ;
    };
in
{
  # Default host: QConfigVM (VM for testing configurations)
  QConfigVM = mkNixosConfiguration "QConfigVM" { isVm = true; };
  
  # Add more hosts as needed:
  # QPC = mkNixosConfiguration "QPC" { };
  # QPC-install = mkNixosConfiguration "QPC" { isInstall = true; };
  # QFrame13 = mkNixosConfiguration "QFrame13" { isLaptop = true; };
  # QFrame13-install = mkNixosConfiguration "QFrame13" {
  #   isInstall = true;
  #   isLaptop = true;
  # };
}

