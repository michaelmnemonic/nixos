{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    nixosConfigurations = {
      pluto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./pluto.nix
        ];
        specialArgs = {
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
