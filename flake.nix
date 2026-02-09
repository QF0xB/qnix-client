{
  description = "QNix Client Configuration";

  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    nixpkgs-stable = {
      url = "github:NixOS/nixpkgs/nixos-25.11";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Impermanence (non-persistent root (/))
    impermanence = {
      url = "github:nix-community/impermanence";
    };

    # Secret manager SOPS
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Astal (for AGS/AstalHyprland, etc.)
    astal = {
      url = "github:Aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # AGS (Astal Gtk Shell)
    ags = {
      url = "github:Aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # NVF (Neovim File Manager)
    nvf = {
      url = "github:notashelf/nvf/8e031476d0d7f326b63c9c5522f840e2f8b724c0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Global styling
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # QNix modules
    qnix-modules = {
      # Recommended: Use FlakeHub (with version tag)
      # url = "flakehub:your-org/qnix-modules/v2025.01.15.1";
      # Or use github directly: "github:your-org/qnix-modules"
      url = "github:QF0xB/qnix-modules/dev";
      # Or use a local path during development:
      # url = "path:/home/lcqbraendli/projects/qnix/qnix-modules";
    };

    qnix-ags = {
      url = "github:qf0xb/qnix-ags/develop";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    qnix-pkgs = {
      url = "github:qf0xb/qnix-pkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.garnix.io"
    ];
    extra-trusted-public-keys = [
      "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
    ];
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

      # Extend nixpkgs.lib with qnix-modules utilities
      lib = inputs.qnix-modules.lib {
        lib = nixpkgs.lib;
        pkgs = pkgs;
      };

      nixosConfs = import ./hosts/nixos-hosts.nix {
        inherit inputs pkgs lib;
        specialArgs = {
          # Pass categories for client (core + desktop)
          categories = [
            "core"
            "desktop"
          ];

          # Pass only selected inputs that modules need
          # Modules access these via: inputs.nvf, inputs.ags, etc.
          inputs = {
            ags = inputs.ags;
            qnix-ags = inputs.qnix-ags;
            astal = inputs.astal;
          };
        };
      };
    in
    {
      nixosConfigurations = nixosConfs;

      # Build VMs with bootloader support for testing boot configurations
      # Usage: nix build .#vms.QConfigVM && ./result/bin/run-QConfigVM-vm
      vms = lib.mapAttrs (name: config: config.config.system.build.vm) nixosConfs;
      vmsb = lib.mapAttrs (name: config: config.config.system.build.vmWithBootLoader) nixosConfs;
    };
}
