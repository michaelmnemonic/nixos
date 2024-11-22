{
  umu,
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_shared/common.nix
    ./hardware/pluto.nix
    ./mounts/orpheus-nfs.nix
    ./programs/direnv.nix
    ./programs/steam.nix
    ./services/audio.nix
    ./services/chipcards.nix
    ./services/printing.nix
    ./services/scanning.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "pluto";

  # Set kernel parameters
  boot.kernelParams = [
    # Disable mitigiations for some extra performance
    "mitigations=off"
    # Allow overclocking of GPU
    "amdgpu.ppfeaturemask=0xfff7ffff"
    # Use pstate_epp for CPU reclocking
    "amd_pstate=active"
  ];

  # Overclock and undervolt AMD GPU
  environment.etc."tmpfiles.d/gpu-undervolt.conf".text = ''
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - vo -100\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - m 1 1200\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - c\n
  '';

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable lanzaboote
  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  # Boot splash screen
  boot.plymouth.enable = true;

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

  # Use NetworkManager
  networking.networkmanager.enable = true;

  # Disable NetworkManager wait online
  systemd.services."NetworkManager-wait-online".enable = false;

  # Enable mDNS
  services.avahi.enable = true;

  # Add inter, jetbrains-mono and noto fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    (catppuccin-kde.override {
      flavour = ["mocha" "latte"];
      accents = ["rosewater"];
    })
    (umu.packages.${pkgs.system}.umu)
    aspell
    aspellDicts.de
    aspellDicts.en
    fan2go
    ffmpegthumbs
    firefox
    fooyin
    gitMinimal
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-notes
    kdePackages.akonadi-search
    kdePackages.elisa
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    libreoffice-qt
    lm_sensors
    nfs-utils
    sbctl
    syncthing
    transmission_4-qt
    unar
    mpv
  ];

  # Enable user service for syncthing
  systemd.user.services.syncthing.wantedBy = ["default.target"];

  # Enable custom fan control
  boot.kernelModules = ["nct6775"]; # motherboard sesnsors
  environment.etc."fan2go/fan2go.yaml".text = ''
    fans:
      - id: front_bottom
        hwmon:
          platform: nct6798-isa-0290
          index: 1
        neverStop: true
        curve: front_curve
      - id: front_top
        hwmon:
          platform: nct6798-isa-0290
          index: 5
        neverStop: true
        curve: front_curve
      - id: top
        hwmon:
          platform: nct6798-isa-0290
          index: 7
        neverStop: true
        curve: front_curve
      - id: back
        hwmon:
          platform: nct6798-isa-0290
          index: 6
        neverStop: true
        curve: cpu_curve
      - id: cpu
        hwmon:
          platform: nct6798-isa-0290
          index: 2
        neverStop: true
        curve: cpu_curve
      - id: gpu
        hwmon:
          platform: nct6798-isa-0290
          index: 4
        neverStop: true
        curve: gpu_curve
    sensors:
      - id: gpu_edge
        hwmon:
          platform: amdgpu-pci-0a00
          index: 1
      - id: gpu_mem
        hwmon:
          platform: amdgpu-pci-0a00
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
            - 70: 130
      - id: gpu_mem_curve
        linear:
          sensor: gpu_mem
          steps:
            - 70: 80
            - 90: 100
            - 100: 150
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
      - id: front_curve
        function:
          type: maximum
          curves:
            - front_cpu_curve
            - front_gpu_curve
      - id: front_cpu_curve
        linear:
          sensor: cpu_tctl
          steps:
            - 50: 50
            - 60: 70
            - 70: 110
      - id: front_gpu_curve
        linear:
          sensor: gpu_edge
          steps:
            - 55: 50
            - 60: 110
            - 65: 150
  '';
  systemd.services.fan2go = {
    enable = true;
    after = ["lm-sensors.service"];
    description = "Advanced Fan Control program";
    path = [pkgs.procps];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1s";
      ExecStart = ''${pkgs.fan2go}/bin/fan2go -c /etc/fan2go/fan2go.yaml --no-style'';
    };
    wantedBy = ["multi-user.target"];
  };

  # load ath11k modules after suspend
  systemd.services.ath11k-resume = {
    description = "Load ath11k_pci module after suspend";
    after = ["suspend.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kmod}/bin/modprobe ath11k_pci'';
    };
    wantedBy = ["suspend.target"];
  };

  # unload ath11k modules before suspend
  systemd.services.ath11k-suspend = {
    description = "Unload ath11k_pci module before suspend";
    before = ["sleep.target"];
    serviceConfig = {
      Type = "simple";
      ExecStart = ''${pkgs.kmod}/bin/rmmod ath11k_pci'';
    };
    wantedBy = ["sleep.target"];
  };

  # Setup firewall
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

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
  };

  # Enable gamescope
  programs.gamescope = {
    enable = true;
  };

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  # Enable gamemode
  programs.gamemode = {
    enable = true;
    settings = {
      general. renice = 10;
    };
  };

  # Enable ssh-agent
  programs.ssh.startAgent = true;

  # Auto updagrade from github repository
  system.autoUpgrade.flake = "github:michaelmnemonic/nixos";

  system.stateVersion = "24.05";
}
