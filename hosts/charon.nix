{
  inputs,
  pkgs,
  nixos-x13s,
  lib,
  ...
}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/charon.nix
    # Users
    ../users/maik.nix
    # PLASMA desktop
    ../gui/plasma.nix
    # SSH
    ../capabilities/ssh.nix
    # vscodium
    ../capabilities/vscodium.nix
    # Basic capabilites
    ../capabilities/pipewire.nix
    ../capabilities/printing.nix
    ../capabilities/scanning.nix
    ../capabilities/chipcards.nix
  ];

  # Enable X13S support
  # FIXME: logically this belongs is hardware-specifc, but flake only import one level deep 🤔
  nixos-x13s = {
    enable = true;
    wifiMac = "F4:A8:0D:F5:5D:BC";
    bluetoothMac = "F4:A8:0D:30:9D:8B";
    kernel = "jhovold";
  };

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Network configuration
  networking.hostName = "charon";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;
  networking.modemmanager.fccUnlockScripts = [
    {
      id = "105b:e0c3";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
    }
  ];

  # Autologin with greetd
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.kdePackages.plasma-workspace}/bin/startplasma-wayland";
        user = "maik";
      };
      default_session = initial_session;
    };
  };

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # syncthing
      22000 # sync
      # transmission
      43219
    ];
    allowedTCPPortRanges = [
      # kdeconnect
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPorts = [
      # syncthing
      22000
      21027
      # transmission
      43219
    ];
    allowedUDPPortRanges = [
      # kdeconnect
      {
        from = 1714;
        to = 1764;
      }
    ];
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 1637 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 1637 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 1637 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 1637 -j RETURN || true
    '';
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    kodi
    neovim
    zed-editor
  ];

  # Make sure syncthing home exists
  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # Make fish shell availlable
  programs.fish.enable = true;

  ############
  # Services #
  ############

  # Enable mDNS
  services.avahi.enable = true;

  # syncthing
  services.syncthing = {
    enable = true;
    user = "maik";
  };

  # NixOS state version
  system.stateVersion = "24.05";
}
