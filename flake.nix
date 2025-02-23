{
  description = "A very basic flake";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      follows = "nixpkgs-unstable";
    };

    nixos-x13s = {
      url = "github:michaelmnemonic/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    home-manager,
    nixos-x13s,
  }: {
    nixosConfigurations = {
      pluto = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./pluto.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.maik = import ./homes/maik.nix;

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
        specialArgs = {
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
