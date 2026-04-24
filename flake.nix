{
  description = "QNix Client Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nvf = {
      url = "github:notashelf/nvf";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence.url = "github:nix-community/impermanence";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    qnix-modules = {
      # Managed by qnix-dev-modules and qnix-use-release.
      url = "https://flakehub.com/f/QF0xB/qnix-modules/=0.8.1";
    };

    qnix-pkgs = {
      url = "github:QF0xB/qnix-pkgs";
      inputs.nixpkgs.follows = "nixpkgs";
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

  outputs = {nixpkgs, ...} @ inputs: let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
      overlays = [
        inputs.qnix-pkgs.overlays.default
      ];
    };

    qnixLib = inputs.qnix-modules.lib {
      lib = nixpkgs.lib;
      pkgs = pkgs;
    };

    lib = nixpkgs.lib.extend (_final: _prev: qnixLib);

    nixosConfs = import ./hosts/nixos-hosts.nix {
      inherit
        inputs
        pkgs
        lib
        qnixLib
        ;
      specialArgs = {
        defaultUser = "q.braendli";
      };
    };
  in {
    nixosConfigurations = nixosConfs;
  };
}
