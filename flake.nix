{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";

    nixos-x13s = {
      url = "github:michaelmnemonic/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      nixos-x13s,
      agenix,
      caelestia-shell,
    }:
    let
      # Define 'forAllSystems' for properties that shall be build for x86_64 *and* aarch64
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      nixosConfigurations = {
        pluto = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/pluto.nix
            agenix.nixosModules.default
          ];
          specialArgs = {
          };
        };
        juno = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/juno.nix
            agenix.nixosModules.default
          ];
          specialArgs = {
          };
        };
        flore = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/flore.nix
            agenix.nixosModules.default
          ];
          specialArgs = {
          };
        };
        charon = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            ./hosts/charon.nix
            nixos-x13s.nixosModules.default
            agenix.nixosModules.default
          ];
          specialArgs = {
            inherit nixos-x13s caelestia-shell;
          };
        };
      };

      devShell = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system}.pkgs;
        in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            cachix
            gitMinimal
            nil
            ragenix
          ];
        }
      );
    };
}
