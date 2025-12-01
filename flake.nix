{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs/nixos-25.05";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprlauncher = {
      url = "github:hyprwm/hyprlauncher";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermenance (non-persistent root (/))
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    # Secret manager SOPS
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Global styling
    stylix = {
      url = "github:danth/stylix";
    };

    # Astal (for AGS/AstalHyprland, etc.)
    astal = {
      url = "github:Aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Astal (for AGS/AstalHyprland, etc.)
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qnix-modules = {
      url = "git+ssh://git@github.com/QF0xB/qnix-modules.git?ref=feature/ags";

      inputs.qnix-pkgs.follows = "qnix-pkgs";
    };

    qnix-pkgs = {
      url = "github:qf0xb/qnix-pkgs";
    };
  };

  outputs =
    { nixpkgs, nixpkgs-stable, ... }@inputs:
    let
      system = "x86_64-linux";
      stableOverlay = final: prev: {
        stable = import nixpkgs-stable {
          inherit system;
          config = prev.config;
        };
      };

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;

        overlays = [
          inputs.qnix-pkgs.overlays.default
          stableOverlay
        ];
      };

      lib = inputs.qnix-modules.lib;

      nixosConfs = import ./hosts/nixos-hosts.nix {
        inherit
          inputs
          pkgs
          lib
          ;
        specialArgs = { };
      };

    in
    {
      nixosConfigurations = nixosConfs;
    };
}
