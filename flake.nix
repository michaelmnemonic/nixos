{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";

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
    pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});

    allowed-unfree-packages = [
      "widevine-cdm"
      "widevine-firefox"
      "self.packages.widevine-firefox"
    ];
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
          ragenix.nixosModules.default
        ];
        specialArgs = {
        };
      };
      charon = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        modules = [
          nixos-x13s.nixosModules.default
          ./hosts/charon.nix
          ragenix.nixosModules.default
        ];
        specialArgs = {
          inherit nixos-x13s self allowed-unfree-packages;
        };
      };
    };

    packages = import ./pkgs nixpkgs.legacyPackages.aarch64-linux;

    devShell = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system}.pkgs;
    in
      pkgs.mkShell {
        buildInputs = [
          ragenix.packages.${system}.ragenix
          pkgs.gitMinimal
          pkgs.nil
          pkgs.alejandra
        ];
      });
  };
}
