{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
  };

  outputs = {
    self,
    nixpkgs,
  }: {
    nixosConfigurations.pluto = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./pluto.nix
      ];
    };
    devShell.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.pkgs.mkShell {
      buildInputs = [
        nixpkgs.legacyPackages.x86_64-linux.pkgs.gitMinimal
        nixpkgs.legacyPackages.x86_64-linux.pkgs.nil
        nixpkgs.legacyPackages.x86_64-linux.pkgs.alejandra
      ];
    };
  };
}
