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
  ];

  ###########
  # Secrets #
  ###########

  age.secrets = {
    "pluto-flore.key" = {
      file = ../secrets/pluto-flore.key.age;
      owner = "root";
      group = "root";
    };
    "orpheus_flore.psk" = {
      file = ../secrets/orpheus_flore.psk.age;
      owner = "root";
      group = "root";
    };
  };

  ##############
  # Networking #
  ##############

  networking.networkmanager.unmanaged = ["Unterwelt"];
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    Unterwelt = {
      ips = ["10.0.0.10/24"];
      listenPort = 51823;
      privateKeyFile = config.age.secrets."pluto-flore.key".path;
      peers = [
        # orpheus
        {
          publicKey = "b2D3/C+3yCuzNGW4zYZ8vUMFIO1MUeAp8DoVfjbv3QQ=";
          presharedKeyFile = config.age.secrets."orpheus_flore.psk".path;
          allowedIPs = ["10.0.0.0/24"];
          endpoint = "maikkoehler.eu:51820";
          dynamicEndpointRefreshSeconds = 60;
        }
      ];
    };
  };

  networking.extraHosts = ''
    10.0.0.1 orpheus
    10.0.0.2 charon
    10.0.0.3 pluto
    10.0.0.10 flore
  '';

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
