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
      extraConfig ? { },
    }:
    lib.nixosSystem {
      inherit pkgs;

      specialArgs = specialArgs // {
        inherit
          host
          isVm
          isInstall
          isLaptop
          isNixOS
          user
          ;
        dots = "/persist/home/${user}/projects/dotfiles";
      };

      modules = [
        inputs.qnix-modules.nixosModules.qnix

        {
          environment.systemPackages = [ pkgs.fh ];
        }

        ./${host}/configuration.nix
        ./${host}/hardware.nix

        inputs.home-manager.nixosModules.home-manager

        {
          nix.settings.trusted-users = [ user ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;

            extraSpecialArgs = specialArgs // {
              inherit
                host
                isVm
                isInstall
                isLaptop
                isNixOS
                user
                ;
              dots = "/persist/home/${user}/projects/dotfiles";
            };

            users.${user} = {
              imports = [
                inputs.qnix-modules.homeManagerModules.qnix
                ./${host}/home.nix
                ./${host}/qnix.nix # <- Module options

                inputs.nvf.homeManagerModules.default
              ];
            };
          };
        }

        inputs.impermanence.nixosModules.impermanence # single-use root (/)
        inputs.sops-nix.nixosModules.sops # secret management

        (lib.mkAliasOptionModule [ "hm" ] [ "home-manager" "users" user ])

        extraConfig
      ];
    };
in
{
  QPC = mkNixosConfiguration "QPC" { };
  QPC-install = mkNixosConfiguration "QPC" { isInstall = true; };
  QFrame13 = mkNixosConfiguration "QFrame13" { isLaptop = true; };
  QFrame13-install = mkNixosConfiguration "QFrame13" {
    isInstall = true;
    isLaptop = true;
  };
  QConfigVM = mkNixosConfiguration "QConfigVM" { isVm = true; };
}
