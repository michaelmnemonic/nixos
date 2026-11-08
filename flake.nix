{
  description = "Nix configuration for several private host systems";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-26.05";

    agenix = {
      url = "github:yaxitech/ragenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vibepanel = {
      url = "github:prankstr/vibepanel/8d09e7d358b3d83dc84f20466dee8414b73a9dbf"; # v0.17.2
      inputs.nixpkgs.follows = "nixpkgs";
    };

    voxtype = {
      url = "github:peteonrails/voxtype/8d49248baa53f29cb33007c9625a37281c72e799"; # v0.7.5
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

    veila = {
      url = "github:naurissteins/Veila";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    aagl,
    agenix,
    intel-lpmd-flake,
    lanzaboote,
    nixpkgs,
    veila,
    vibepanel,
    voxtype,
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
      styx = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./hosts/styx.nix
          aagl.nixosModules.default
          agenix.nixosModules.default
          intel-lpmd-flake.nixosModules.default
          lanzaboote.nixosModules.lanzaboote
          veila.nixosModules.default
        ];
        specialArgs = {
          inherit vibepanel;
          inherit voxtype;
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
        styx = pkgs.testers.nixosTest (import ./tests/styx.nix {inherit aagl agenix intel-lpmd-flake lanzaboote vibepanel voxtype;});
        juno = pkgs.testers.nixosTest (import ./tests/juno.nix {inherit agenix;});
        flore = pkgs.testers.nixosTest (import ./tests/flore.nix {inherit agenix;});
      }
    );
  };
}
