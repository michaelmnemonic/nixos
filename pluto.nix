{pkgs, ...}: {
  imports = [
    ./hardware/pluto.nix
    ./_shared/common.nix
  ];

  # Disable mitigations for performance
  # FIXME: is this a good idea?
  boot.kernelParams = [
    "mitigations=off"
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  system.autoUpgrade.flake = "github:michaelmnemonic/nixos";
  system.stateVersion = "24.05"; # Did you read the comment?
}
