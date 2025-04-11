{
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/pluto.nix
    # Users
    ../users/maik.nix
    # PLASMA desktop
    ../gui/plasma.nix
    # SSH
    ../capabilities/ssh.nix
    # vscodium
    ../capabilities/vscodium.nix
    # Fan control with fan2go
    ../capabilities/fan2go.nix
    # Software deployment platform steam
    ../capabilities/steam.nix
    # Audio and video via pipwire
    ../capabilities/pipewire.nix
    # Chipcards via pcscd
    ../capabilities/chipcards.nix
    # Printing
    ../capabilities/printing.nix
    # Scanning
    ../capabilities/scanning.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network configuration
  networking.hostName = "pluto";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;

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

  environment.systemPackages = with pkgs; [
    gamescope-wsi
    neovim
    wineWowPackages.staging
    vulkan-hdr-layer-kwin6
    zed-editor
  ];

  # Not all software is free
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "libvgm" # dependency of fooyin
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];

  #####################
  # ETC configuration #
  #####################

  # Overclock and undervolt AMD GPU
  environment.etc."tmpfiles.d/gpu-undervolt.conf".text = ''
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - vo -100\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - m 1 1200\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - c\n
  '';

  # Make sure syncthing home exists
  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

  # Fan control
  environment.etc."fan2go/fan2go.yaml".text = ''
    fans:
      - id: side
        hwmon:
          platform: nct6792-isa-0290
          index: 1
        neverStop: true
        curve: side_curve
      - id: cpu
        hwmon:
          platform: nct6792-isa-0290
          index: 2
        neverStop: true
        curve: cpu_curve
      - id: bottom
        hwmon:
          platform: nct6792-isa-0290
          index: 3
        neverStop: true
        curve: gpu_curve
    sensors:
      - id: gpu_edge
        hwmon:
          platform: amdgpu-pci-0800
          index: 1
      - id: gpu_mem
        hwmon:
          platform: amdgpu-pci-0800
          index: 3
      - id: cpu_tctl
        hwmon:
          platform: k10temp-pci-00c3
          index: 1
    curves:
      - id: gpu_edge_curve
        linear:
          sensor: gpu_edge
          steps:
            - 50: 80
            - 60: 100
            - 70: 150
      - id: gpu_mem_curve
        linear:
          sensor: gpu_mem
          steps:
            - 70: 80
            - 90: 100
            - 100: 160
      - id: gpu_curve
        function:
          type: maximum
          curves:
            - gpu_edge_curve
            - gpu_mem_curve
      - id: cpu_curve
        linear:
          sensor: cpu_tctl
          steps:
            - 50: 80
            - 60: 100
            - 70: 130
      - id: side_curve
        function:
          type: maximum
          curves:
            - cpu_curve
            - gpu_curve
  '';

  ############
  # Programs #
  ############

  # Enable gamemode
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
    };
  };

  # Enable gamescope
  programs.gamescope.enable = true;

  ############
  # Services #
  ############

  # Enable mDNS
  services.avahi.enable = true;

  # Enable ollama
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
  };

  # NixOS state version
  system.stateVersion = "24.05";
}
