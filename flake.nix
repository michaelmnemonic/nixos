{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-24.11";

    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixos-x13s = {
      url = "github:michaelmnemonic/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs = {
    self,
    nixpkgs-stable,
    nixpkgs-unstable,
    nixos-x13s,
  }: let
    # Define 'forAllSystems' for properties that shall be build for x86_64 *and* aarch64
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs-unstable.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      pluto = nixpkgs-unstable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/pluto.nix
        ];
        specialArgs = {
        };
      };
      juno = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/juno.nix
        ];
        specialArgs = {
        };
      };
      charon = nixpkgs-unstable.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-x13s.nixosModules.default
          ./hosts/charon.nix
        ];
        specialArgs = {
          inherit nixos-x13s;
        };
      };
    };
    devShell = forAllSystems (system:
      let
        pkgs = nixpkgs-unstable.legacyPackages.${system}.pkgs;
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            gitMinimal
            nil
            alejandra
          ];
      });
    };
}
