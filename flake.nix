{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    intel-lpmd-flake = {
      url = "github:dmfrpro/intel-lpmd-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/7c9a54a7f87b4539ddbd8bda09a8a5f5f9361aa9"; # v1.1.0
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    agenix,
    intel-lpmd-flake,
    lanzaboote,
    nixpkgs,
  }: let
    # Define  architectures to build for 'forAllSystems'
    systems = [
      "x86_64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      pluto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/pluto.nix
          agenix.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
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
      styx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/styx.nix
          agenix.nixosModules.default
          intel-lpmd-flake.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
        ];
        specialArgs = {
        };
      };
    };

    packages = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        kiot = pkgs.kdePackages.callPackage ./pkgs/kiot {};
      }
    );

    devShell = forAllSystems (
      system: let
        pkgs = nixpkgs.legacyPackages.${system}.pkgs;
      in
        pkgs.mkShell {
          buildInputs = with pkgs; [
            alejandra
            cachix
            gitMinimal
            nil
            ragenix
            sbctl
          ];
        }
    );

    checks = forAllSystems (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            permittedInsecurePackages = [
              "olm-3.2.16"
            ];
          };
        };
      in {
        pluto = pkgs.testers.nixosTest (import ./tests/pluto.nix {inherit agenix lanzaboote;});
        styx = pkgs.testers.nixosTest (import ./tests/styx.nix {inherit agenix intel-lpmd-flake lanzaboote;});
        juno = pkgs.testers.nixosTest (import ./tests/juno.nix {inherit agenix;});
        flore = pkgs.testers.nixosTest (import ./tests/flore.nix {inherit agenix;});
      }
    );
  };
}
