{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = with inputs.self.nixosModules; [
    # Shared host configuration
    hosts-shared
    # Hardware configuration
    hosts-charon
    # Users
    users-maik
    # PLASMA desktio
    gui-plasma
    # SSH
    ssh
    # vscodium
    vscodium
    # Basic capabilites
    pipewire
    printing
    scanning
    chipcards
  ];

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
  ];

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

  nix = {
    settings = {
      cores = 3;
      max-jobs = 1;
    };
  };

  # NixOS state version
  system.stateVersion = "24.05";
}
