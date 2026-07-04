{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    nixos-x13s = {
      url = "github:michaelmnemonic/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vibepanel = {
      url = "github:prankstr/vibepanel/9cabdf92766ec756d4ffbf2aea739220a4a368dc"; # v0.15.0
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voxtype = {
      url = "github:peteonrails/voxtype/8d49248baa53f29cb33007c9625a37281c72e799"; # v0.7.5
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixos-x13s,
    agenix,
    vibepanel,
    voxtype,
  }: let
    # Define 'forAllSystems' for properties that shall be build for x86_64 *and* aarch64
    systems = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    forAllSystems = nixpkgs.lib.genAttrs systems;
  in {
    nixosConfigurations = {
      pluto = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/pluto.nix
          agenix.nixosModules.default
        ];
        specialArgs = {
          inherit vibepanel;
          inherit voxtype;
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
          inherit nixos-x13s;
          inherit vibepanel;
          inherit voxtype;
        };
      };
    };

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
            cachix
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
        pluto = pkgs.testers.nixosTest (import ./tests/pluto.nix {inherit agenix;});
        juno = pkgs.testers.nixosTest (import ./tests/juno.nix {inherit agenix;});
        flore = pkgs.testers.nixosTest (import ./tests/flore.nix {inherit agenix;});
        charon = pkgs.testers.nixosTest (
          import ./tests/charon.nix {
            inherit agenix nixos-x13s vibepanel voxtype;
          }
        );
      }
    );
  };
}
