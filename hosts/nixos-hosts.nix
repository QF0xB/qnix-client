{
  inputs,
  pkgs,
  lib,
  specialArgs,
  ...
}@args:
let
  defaultCategories =
    if specialArgs ? defaultCategories then
      specialArgs.defaultCategories
    else
      [
        "core"
        "desktop"
      ];

  # Host-specific category selection allows reducing module eval scope per host.
  categoryOverrides = {
    QConfigVM = [
      "core"
      "desktop"
    ];
    QTestVM = [
      "core"
      "desktop"
    ];
    QFrame13 = [
      "core"
      "desktop"
    ];
    QPCv1 = [
      "core"
      "desktop"
    ];
    QPCv2 = [
      "core"
      "desktop"
    ];
  };

  mkHostConfiguration =
    host: hostArgs:
    mkNixosConfiguration host (
      hostArgs
      // {
        categories = categoryOverrides.${host} or defaultCategories;
      }
    );

  mkNixosConfiguration =
    host:
    {
      pkgs ? args.pkgs,
      categories ? defaultCategories,
      user ? "q.braendli",
      isVm ? false,
      isInstall ? false,
      isLaptop ? false,
      isNixOS ? true,
      loadOptions ? true,
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
        inherit categories;
        dots = "/persist/home/${user}/projects/qnix/client";
      };

      modules = [
        # Host-specific configuration
        # ./${host}/qnix.nix

        ./${host}/configuration.nix
        ./${host}/qnix.nix # qnix.* options for this host
        ./${host}/hardware.nix

        # Load QNix modules (will use categories from specialArgs)
        inputs.qnix-modules.nixosModules.qnix

        {
          qnix.persist.home.files = [
            ".local/share/nix/trusted-settings.json"
          ];
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
              inherit categories;
              dots = "/persist/home/${user}/projects/qnix/client";

            };

            users.${user} = {
              imports = [
                inputs.qnix-modules.homeManagerModules.qnix
                # Load QNix Home Manager modules (will use categories from specialArgs)
                ./${host}/home.nix

                inputs.noctalia.homeModules.default
                inputs.qnix-modules.homeManagerModules.qnixNoctaliaIntegration

                inputs.nvf.homeManagerModules.default
              ];
            };
          };
        }

        # Other modules
        inputs.impermanence.nixosModules.impermanence
        inputs.qnix-modules.nixosModules.qnixImpermanenceIntegration

        inputs.disko.nixosModules.disko

        inputs.stylix.nixosModules.stylix

        inputs.sops-nix.nixosModules.sops
        inputs.qnix-modules.nixosModules.qnixSopsIntegration

        inputs.qnix-pkgs.nixosModules.default

        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])

        extraConfig
      ]
      # Import host-specific disko configuration if it exists
      ++ lib.optional (builtins.pathExists ./${host}/disko.nix) ./${host}/disko.nix;
    };
in
{
  # Default host: QConfigVM (VM for testing configurations)
  QConfigVM = mkHostConfiguration "QConfigVM" { isVm = true; };
  QTestVM = mkHostConfiguration "QTestVM" { isVm = true; };

  QFrame13 = mkHostConfiguration "QFrame13" { isLaptop = true; };
  QPCv1 = mkHostConfiguration "QPCv1" { };
  QPCv2 = mkHostConfiguration "QPCv2" { };

  # Add more hosts as needed:
  # QPC = mkNixosConfiguration "QPC" { };
  # QPC-install = mkNixosConfiguration "QPC" { isInstall = true; };
  # QFrame13 = mkNixosConfiguration "QFrame13" { isLaptop = true; };
  # QFrame13-install = mkNixosConfiguration "QFrame13" {
  #   isInstall = true;
  #   isLaptop = true;
  # };
}
