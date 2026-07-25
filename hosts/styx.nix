{pkgs, ...}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/styx.nix
    # Users
    ../users/maik.nix
    # plasma desktop environment
    ../gui/plasma.nix
    # Basic capabilities
    ../capabilities/chipcards.nix
    ../capabilities/networking-with-network-manager.nix
    ../capabilities/pipewire.nix
    ../capabilities/plasma-pim.nix
    ../capabilities/printing.nix
    ../capabilities/ssh.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network configuration
  networking.hostName = "styx";

  # Manage displays with SDDM
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "maik";
    };
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    firefox
    kdePackages.tokodon
    kdePackages.neochat
  ];

  # Customize kde plasma
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (sfinal: sprev: {
        # smaller systemtray icons with more spacing
        # FIXME: this compiles plasma-workspace just to patch qml script
        plasma-workspace = sprev.plasma-workspace.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches
            ++ [
              ../patches/0001-plasma-workspaces-systemtray-icon-sizes.patch
            ];
        });
      });
    })
  ];

  # Make sure mount point of user home exists
  environment.etc."tmpfiles.d/home-maik.conf".text = ''
    d /home/maik               700 1000 100 -
  '';

  # Mount subvolume that contains the user home
  systemd.mounts = [
    {
      type = "btrfs";
      mountConfig = {
        Options = "subvol=@maik";
      };
      what = "LABEL=NIXOS";
      where = "/home/maik";
    }
  ];

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # NixOS state version
  system.stateVersion = "24.05";
}
