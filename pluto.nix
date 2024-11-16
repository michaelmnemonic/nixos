{pkgs, ...}: {
  imports = [
    ./hardware/pluto.nix
    ./_shared/common.nix
    ./users/maik.nix
  ];

  # Disable mitigations for performance
  # FIXME: is this a good idea?
  boot.kernelParams = [
    "mitigations=off"
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use german keyboard layout
  services.xserver = {
    # set keymap
    xkb.layout = "de";
  };

  # Use plasma as desktop environment
  services.desktopManager.plasma6.enable = true;

  # Use SDDM as displayManager
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };
  };

  system.autoUpgrade.flake = "github:michaelmnemonic/nixos";
  system.stateVersion = "24.05"; # Did you read the comment?
}
