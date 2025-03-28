{
  description = "Nix configuration for several private host systems";

  # Add all your dependencies here
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    blueprint = {
      url = "github:numtide/blueprint";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-x13s = {
      url = "github:michaelmnemonic/x13s-nixos";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  # Load the blueprint
  outputs = inputs: inputs.blueprint {inherit inputs;};
}
