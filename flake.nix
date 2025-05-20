{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    ragenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-x13s = {
      url = "github:michaelmnemonic/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ragenix,
    nixos-x13s,
  }: let
    # Define 'forAllSystems' for properties that shall be build for x86_64 *and* aarch64
    systems = ["x86_64-linux" "aarch64-linux"];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      pluto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/pluto.nix
          ragenix.nixosModules.default
        ];
        specialArgs = {
        };
      };
      juno = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/juno.nix
        ];
        specialArgs = {
        };
      };
      charon = nixpkgs.lib.nixosSystem {
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
        pkgs = nixpkgs.legacyPackages.${system}.pkgs;
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            gitMinimal
            nil
            alejandra
            ragenix
          ];
        });
    };
}
