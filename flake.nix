{
  inputs = {
    nixpkgs = {
      url = "github:NixOS/nixpkgs/nixos-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
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

    qnix-modules = {
      url = "git+ssh://git@github.com/QF0xB/qnix-modules.git?ref=develop"; # https://flakehub.com/f/QF0xB/qnix-modules-develop/0.0.1"; # /0.1.17";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.impermanence.follows = "impermanence";
      inputs.sops-nix.follows = "sops-nix";
      inputs.nvf.follows = "nvf";
    };
  };

  outputs =
    { nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
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
