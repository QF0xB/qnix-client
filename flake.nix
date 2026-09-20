{
  description = "QNix client configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nixos-hardware.url = "github:NixOS/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-shell = {
      url = "github:noctalia-dev/noctalia-shell/legacy-v4";
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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";

    qnix-sdk.url = "github:QF0xB/qnix-sdk";

    qnix-modules = {
      # Managed by qnix-dev-modules and qnix-use-release.
      url = "https://flakehub.com/f/QF0xB/qnix-modules/0.15.4";
      inputs.qnix-sdk.follows = "qnix-sdk";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      nixos-hardware,
      home-manager,
      stylix,
      noctalia-shell,
      nvf,
      impermanence,
      sops-nix,
      disko,
      llm-agents,
      mcp-servers-nix,
      qnix-modules,
      ...
    }:
    let
      system = "x86_64-linux";
      mcpServersNix = mcp-servers-nix // {
        lib = mcp-servers-nix.lib // {
          evalModule = pkgs: config:
            mcp-servers-nix.lib.evalModule pkgs (
              pkgs.lib.recursiveUpdate config {
                programs.filesystem.package =
                  nixpkgs.legacyPackages.${system}.mcp-server-filesystem;
              }
            );
        };
      };
    in
    {
      nixosConfigurations = import ./hosts/nixos-hosts.nix {
        inherit
          disko
          home-manager
          impermanence
          sops-nix
          inputs
          llm-agents
          noctalia-shell
          nixpkgs
          nixos-hardware
          nvf
          qnix-modules
          system
          stylix
          ;
        mcp-servers-nix = mcpServersNix;
      };
    };
}
