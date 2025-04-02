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
    }: {
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
