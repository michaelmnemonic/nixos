{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    widevine = {
      url = "github:ExpidusOS/nixpkgs?ref=feat/widevine-again";
    };

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
    widevine,
  }: let
    system = "aarch64-linux";
    overlay-widevine = final: prev: {
      widevine-overlay = import widevine {
        inherit system;
        config.allowUnfree = true;
      };
    };
  in {
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
          ({
            config,
            pkgs,
            ...
          }: {nixpkgs.overlays = [overlay-widevine];})
          ./charon.nix
        ];
        specialArgs = {
          inherit widevine;
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
    devShell.aarch64-linux = nixpkgs.legacyPackages.aarch64-linux.pkgs.mkShell {
      buildInputs = with nixpkgs.legacyPackages.aarch64-linux.pkgs; [
        gitMinimal
        nil
        alejandra
      ];
    };
  };
}
