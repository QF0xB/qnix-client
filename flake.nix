{
  description = "QNix client configurations";

  nixConfig = {
    extra-substituters = [ "https://cache.numtide.com" ];
    extra-trusted-public-keys = [
      "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
    ];
  };

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

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix.url = "github:natsukium/mcp-servers-nix";

    qnix-sdk.url = "path:/persist/home/q.braendli/projects/qnix/sdk";

    qnix-modules = {
      url = "path:/persist/home/q.braendli/projects/qnix/modules";
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
      disko,
      llm-agents,
      mcp-servers-nix,
      qnix-modules,
      ...
    }:
    let
      system = "x86_64-linux";
      qnix = qnix-modules.lib.mkQNix {
        context = {
          hostname = "QTestVM";
          vm = true;
          inherit mcp-servers-nix;
        };
      };
    in
    {
      nixosConfigurations = import ./hosts/nixos-hosts.nix {
        inherit
          disko
          home-manager
          impermanence
          inputs
          llm-agents
          noctalia-shell
          nixpkgs
          nixos-hardware
          nvf
          qnix
          system
          stylix
          ;
      };
    };
}
