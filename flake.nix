{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    umu = {
      url = "github:Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1/1.1.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-x13s = {
      url = "github:BrainWart/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    umu,
    nixos-x13s,
  }: {
    nixosConfigurations = {
      pluto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./pluto.nix
        ];
        specialArgs = {
          inherit umu;
        };
      };
      juno = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./juno.nix
        ];
        specialArgs = {
        };
      };
      charon = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-x13s.nixosModules.default
          ./charon.nix
        ];
        specialArgs = {
        };
      };
    };
    devShell.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.pkgs.mkShell {
      buildInputs = with nixpkgs.legacyPackages.x86_64-linux.pkgs; [
        gitMinimal
        nil
        alejandra
      ];
    };
  };
}
