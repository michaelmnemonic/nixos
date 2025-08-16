{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/flore.nix
    # Users
    ../users/maik.nix
    ../users/katrin.nix
    # PLASMA desktop
    ../gui/plasma.nix
    # basic capabilities
    ../capabilities/ssh.nix
    ../capabilities/pipewire.nix
    ../capabilities/chipcards.nix
    ../capabilities/printing.nix
    ../capabilities/scanning.nix
    ../capabilities/wireguard.nix
  ];

  # Network configuration
  networking.hostName = "flore";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Autologin with greetd
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland";
        user = "katrin";
      };
      default_session = initial_session;
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    interfaces."Unterwelt".allowedTCPPorts = [
      # RDP
      3389
    ];
    allowedUDPPorts = [
    ];
    allowedUDPPortRanges = [
    ];
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    noto-fonts
    noto-fonts-emoji
  ];

  environment.systemPackages = with pkgs; [
    thunderbird
  ];

  #####################
  # ETC configuration #
  #####################

  ############
  # Services #
  ############

  # Enable mDNS
  services.avahi.enable = true;

  # NixOS state version
  system.stateVersion = "25.05";
}
