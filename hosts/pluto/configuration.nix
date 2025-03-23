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
    hosts-pluto
    # Users
    users-maik
    # Fan control with fan2go
    fan2go
    # Software deployment platform steam
    steam
    # Audio and video via pipwire
    pipewire
    # Chipcards via pcscd
    chipcards
    # Printing
    printing
    # Scanning
    scanning
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network configuration
  networking.hostName = "pluto";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;

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

  # Use plasma as desktop environment
  services.desktopManager.plasma6.enable = true;

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

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
    aqbanking
    aspell
    aspellDicts.de
    aspellDicts.en
    firefox
    fooyin
    gitMinimal
    haruna
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-search
    kdePackages.ffmpegthumbs
    kdePackages.kcalc
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kio-extras
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    keepassxc
    libcamera
    libreoffice-qt
    mpv
    nfs-utils
    pinentry-qt
    transmission_4-qt
    unar
    vscodium
    vulkan-hdr-layer-kwin6
    wineWowPackages.staging
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

  #########################
  # Environment variables #
  #########################

  # VSCode shall use native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Make ssh-askpass prefer to interactivly ask for password
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

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
  programs.gamescope = {
    enable = true;
  };

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  ############
  # Services #
  ############

  # Enable mDNS
  services.avahi.enable = true;

  # Enable dbus with "dbus-broker" implementation
  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  # Enable SSH server with public key authentication only
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Enable ssh-agent
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  };

  # Enable gnupg
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
  };

  # Enable syncthing
  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "maik";
  };

  # Enable ollama
  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
  };

  ############
  # Overlays #
  ############

  # https://invent.kde.org/plasma/ksshaskpass/-/merge_requests/24
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (sfinal: sprev: {
        ksshaskpass = sprev.ksshaskpass.overrideAttrs (oldAttrs: {
          patches = builtins.fetchurl {
            url = "https://invent.kde.org/plasma/ksshaskpass/-/merge_requests/24.patch";
            sha256 = "sha256:00rqh4bkwy8hhh2fl3pqddilprilanp78zi2l84ggfik4arm52ig";
          };
        });
      });
    })
  ];

  # NixOS state version
  system.stateVersion = "24.05";
}
