{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umu = {
      url = "github:Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1/1.1.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    home-manager,
    nixpkgs,
    lanzaboote,
    umu,
  }: {
    nixosConfigurations.pluto = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        lanzaboote.nixosModules.lanzaboote
        ./pluto.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.maik = import ./home.nix;
        }
      ];
      specialArgs = {inherit umu;};
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
