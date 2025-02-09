{
  description = "A very basic flake";

  inputs = {

    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    umu = {
      url = "github:Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1/1.1.4";
      inputs.nixpkgs.follows = "nixpkgs-stable";
    };

    nixos-x13s = {
      url = "github:BrainWart/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    umu,
    nixos-x13s,
  }:{
    nixosConfigurations = {
      pluto = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./pluto.nix
        ];
        specialArgs = {
          inherit umu;
        };
      };
      juno = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./juno.nix
        ];
        specialArgs = {
        };
      };
      charon = nixpkgs-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-x13s.nixosModules.default
          ./charon.nix
        ];
        specialArgs = {
          inherit nixos-x13s;
        };
      };
    };
    devShell.x86_64-linux = nixpkgs-unstable.legacyPackages.x86_64-linux.pkgs.mkShell {
      buildInputs = with nixpkgs-unstable.legacyPackages.x86_64-linux.pkgs; [
        gitMinimal
        nil
        alejandra
      ];
    };
    devShell.aarch64-linux = nixpkgs-unstable.legacyPackages.aarch64-linux.pkgs.mkShell {
      buildInputs = with nixpkgs-unstable.legacyPackages.aarch64-linux.pkgs; [
        gitMinimal
        nil
        alejandra
      ];
    };
  };
}
