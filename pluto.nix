{pkgs, ...}: {
  imports = [
    ./hardware/pluto.nix
    ./_shared/common.nix
  ];
  system.autoUpgrade.flake = "github:michaelmnemonic/nixos";
  system.stateVersion = "24.05"; # Did you read the comment?
}
