{pkgs, ...}: {
  imports = [
    ./_shared/common.nix
    ./hardware/pluto.nix
    ./mounts/orpheus-nfs.nix
    ./programs/direnv.nix
    ./programs/steam.nix
    ./services/audio-pipewire.nix
    ./services/chipcards.nix
    ./services/printing.nix
    ./services/scanning.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "pluto";

  # Set kernel parameters
  boot.kernelParams = [
    # Allow overclocking of GPU
    "amdgpu.ppfeaturemask=0xfff7ffff"
    # Use pstate_epp for CPU reclocking
    "amd_pstate=active"
  ];

  boot.binfmt.emulatedSystems = ["aarch64-linux"];

  # Overclock and undervolt AMD GPU when gaming, otherwise save power
  environment.etc."tmpfiles.d/gpu-permissions.conf".text = ''
    z  /sys/class/drm/card1/device/pp_od_clk_voltage                664 root wheel - -
    z  /sys/class/drm/card1/device/pp_power_profile_mode            664 root wheel - -
  '';

  environment.etc."gamemode/gpu-performance.conf".text = ''
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - vo -100\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - m 1 1200\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - c\n
  '';

  environment.etc."tmpfiles.d/gpu-manual-performance-level.conf".text = ''
    w /sys/class/drm/card1/device/power_dpm_force_performance_level - - - - manual
  '';

  environment.etc."tmpfiles.d/gpu-powersave.conf".text = ''
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - vo -350\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - m 1 1000\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - s 1 1500\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - c\n
    w /sys/class/drm/card1/device/pp_power_profile_mode             - - - - 2
  '';

  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        renice = 10;
      };
      custom = {
        start = "${pkgs.systemd}/bin/systemd-tmpfiles --create /etc/gamemode/gpu-performance.conf";
        end = "${pkgs.systemd}/bin/systemd-tmpfiles --create /etc/tmpfiles.d/gpu-powersave.conf";
      };
    };
  };

  # customize the desktop
  # FIXME: this compiles plasma-workspace just to patch qml script
  nixpkgs.overlays = [
    (final: prev: {
      # use smaller icons with more spacing in plasma-workspace
      kdePackages = prev.kdePackages.overrideScope (sfinal: sprev: {
        plasma-workspace = sprev.plasma-workspace.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches
            ++ [
              ./patches/0001-plasma-workspaces-systemtray-icon-sizes.patch
              ./patches/0002-plasma-workspaces-lockout-icon-sizes.patch
            ];
        });
      });
    })
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Enable plymouth
  boot.plymouth.enable = true;

  # Early KMS
  boot.initrd.kernelModules = [ "amdgpu" ];

  # Disable ttys
  services.logind.extraConfig = ''
    NAutoVTs=0
    ReserveVT=0
  '';

  # Use german keyboard layout
  services.xserver = {
    enable = true;
    # set keymap
    xkb.layout = "de";
  };

  # Make niri availlable
  programs.niri.enable = true;

  # Make waybar availlable
  programs.waybar.enable = true;

  # Autologin with greetd
  services.greetd = {
    enable = true;
    settings = rec {
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "maik";
      };
      default_session = initial_session;
    };
  };

  # mount subvolume that contains the user home

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

  # make sure mount point of user home exists
  environment.etc."tmpfiles.d/home-maik.conf".text = ''
    d /home/maik               700 1000 100 -
  '';

  # Networking with systemd-networkd and iwd
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."20-wlan" = {
    matchConfig.Name = "wlan*";
    networkConfig.DHCP = "yes";
  };
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };
  networking.wireless.iwd.enable = true;

  # Enable tailscale
  services.tailscale.enable = true;

  # Enable mDNS
  services.avahi.enable = true;

  # Add inter, jetbrains-mono and noto fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    nerdfonts
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    aspell
    aspellDicts.de
    aspellDicts.en
    fan2go
    firefox
    fragments
    fractal
    gitMinimal
    quodlibet
    libreoffice
    mpv
    nautilus
    nfs-utils
    papers
    pavucontrol
    ptyxis
    alacritty
    fuzzel
    thunderbird
    tuba
    vscodium
    zed-editor
  ];

  xdg = {
    autostart.enable = true;
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome];
    };
  };

  # Enable custom fan control
  boot.kernelModules = ["nct6775"]; # motherboard sesnsors
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

  # ssh server with public key authentication only
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
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

  services.syncthing = {
    enable = true;
    openDefaultPorts = true;
    user = "maik";
  };

  # make sure syncthing home exists
  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

  services.ollama = {
    enable = true;
    acceleration = "rocm";
    rocmOverrideGfx = "11.0.0";
  };

  hardware.amdgpu.opencl.enable = true;
  hardware.graphics.extraPackages = with pkgs; [rocmPackages.clr.icd];

  programs.gnupg.agent = {
    enable = true;
  };

  # Enable gamescope
  programs.gamescope = {
    enable = true;
  };

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  # Enable mosh
  programs.mosh.enable = true;

  # Enable ssh-agent
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };

  system.stateVersion = "24.05";
}
