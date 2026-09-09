{
  description = "NixOS configurations for Tim's computers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
      disko,
      sops-nix,
      ...
    }:
    let
      system = "x86_64-linux";
      hosts = [
        "basil"
        "bayleaf"
        "clove"
        "lemongrass"
        "mace"
      ];
      mkHost = name: nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs self; };
        modules = [
          ./hosts/${name}
          disko.nixosModules.disko
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          {
            nixpkgs.config.allowUnfree = true;
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              backupFileExtension = "hm-backup";
              users.tim = import ./modules/home/tim.nix;
            };
          }
        ];
      };
    in
    {
      nixosConfigurations = nixpkgs.lib.genAttrs hosts mkHost;
      checks.${system} = nixpkgs.lib.genAttrs hosts (
        name: self.nixosConfigurations.${name}.config.system.build.toplevel
      );
      formatter.${system} = nixpkgs.legacyPackages.${system}.nixfmt-tree;
    };
}
