{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    umu = {
      url = "github:Open-Wine-Components/umu-launcher/?dir=packaging\/nix&submodules=1/1.1.4";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    agenix,
    nixpkgs,
    lanzaboote,
    umu,
  }: {
    nixosConfigurations.pluto = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        lanzaboote.nixosModules.lanzaboote
        ./pluto.nix
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
