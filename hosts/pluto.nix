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
    ../hardware/pluto.nix
    # Users
    ../users/maik.nix
    # PLASMA desktop
    ../gui/hypr.nix
    # Basic capabilities
    ../capabilities/chipcards.nix
    ../capabilities/fan2go.nix
    ../capabilities/mpv.nix
    ../capabilities/pipewire.nix
    ../capabilities/printing.nix
    ../capabilities/scanning.nix
    ../capabilities/ssh.nix
    ../capabilities/steam.nix
    ../capabilities/vscode.nix
    ../capabilities/wireguard.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network configuration
  networking.hostName = "pluto";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;

  # Emulate aarch64
  boot.binfmt.emulatedSystems = ["aarch64-linux"];

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
        command = "${pkgs.uwsm}/bin/uwsm start hyprland-uwsm.desktop";
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
      3389
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
      # wireguard
      51821
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
    AusweisApp2
    fishPlugins.hydro
    fooyin
    gamescope-wsi
    mangohud
    neovim
    transmission_4-qt
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
      "vscode"
      "vscode-with-extensions"
      "vscode-extension-ms-vscode-remote-remote-ssh"
    ];

  # Enable podman
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
    };
  };

  boot.kernel.sysctl = {
    "vm.max_map_count" = 16777216;
    "fs.file-max" = 524288;
  };

  #####################
  # ETC configuration #
  #####################

  # Overclock and undervolt AMD GPU
  environment.etc."tmpfiles.d/gpu-undervolt.conf".text = ''
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - vo -75\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - m 1 1200\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - c\n
  '';

  # Make sure syncthing home exists
  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

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

  services.pipewire.configPackages = [
    # Provide equalizer for Desktop Speakers
    (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-kef-speakers.conf" ''
      context.modules = [
          { name = libpipewire-module-filter-chain
          args = {
              node.description = "Desktoplautsprecher"
              media.name       = "Desktoplautsprecher"
              filter.graph = {
                  nodes = [
                      {
                          type  = builtin
                          name  = eq_band_1
                          label = bq_peaking
                          control = { "Freq" = 139 "Q" = 3.17 "Gain" = -6.4 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_2
                          label = bq_peaking
                          control = { "Freq" = 184 "Q" = 2.0 "Gain" = -8.8 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_3
                          label = bq_peaking
                          control = { "Freq" = 265 "Q" = 1.79 "Gain" = -7.3 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_4
                          label = bq_peaking
                          control = { "Freq" = 320 "Q" = 1.92 "Gain" = 3.4 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_5
                          label = bq_peaking
                          control = { "Freq" = 327 "Q" = 6.27 "Gain" = -4.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_6
                          label = bq_peaking
                          control = { "Freq" = 1720 "Q" = 7.09 "Gain" = 1.7 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_7
                          label = bq_peaking
                          control = { "Freq" = 1813 "Q" = 3.06 "Gain" = -2.2 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_8
                          label = bq_peaking
                          control = { "Freq" = 2569 "Q" = 1.87 "Gain" = 2.4 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_9
                          label = bq_peaking
                          control = { "Freq" = 2932 "Q" = 2.27 "Gain" = -3.3 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_10
                          label = bq_peaking
                          control = { "Freq" = 4707 "Q" = 4.35 "Gain" = -2.7 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_11
                          label = bq_peaking
                          control = { "Freq" = 5141 "Q" = 1.45 "Gain" = 3.9 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_12
                          label = bq_peaking
                          control = { "Freq" = 6862 "Q" = 1.82 "Gain" = -4.4 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_13
                          label = bq_peaking
                          control = { "Freq" = 11002 "Q" = 1.0 "Gain" = -3.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_14
                          label = bq_peaking
                          control = { "Freq" = 15390 "Q" = 1.53 "Gain" = -3.7 }
                      }
                  ]
                  links = [
                      { output = "eq_band_1:Out" input = "eq_band_2:In" }
                      { output = "eq_band_2:Out" input = "eq_band_3:In" }
                      { output = "eq_band_3:Out" input = "eq_band_4:In" }
                      { output = "eq_band_4:Out" input = "eq_band_5:In" }
                      { output = "eq_band_5:Out" input = "eq_band_6:In" }
                      { output = "eq_band_6:Out" input = "eq_band_7:In" }
                      { output = "eq_band_7:Out" input = "eq_band_8:In" }
                      { output = "eq_band_8:Out" input = "eq_band_9:In" }
                      { output = "eq_band_9:Out" input = "eq_band_10:In" }
                      { output = "eq_band_10:Out" input = "eq_band_11:In" }
                      { output = "eq_band_11:Out" input = "eq_band_12:In" }
                      { output = "eq_band_12:Out" input = "eq_band_13:In" }
                      { output = "eq_band_13:Out" input = "eq_band_14:In" }
                  ]
              }
          audio.channels = 2
          audio.position = [ FL FR ]
              capture.props = {
                  node.name   = "effect_input.eq14"
                  media.class = Audio/Sink
              }
              playback.props = {
                  node.name   = "effect_output.eq14"
                  node.target = "alsa_output.usb-SMSL_SMSL_USB_AUDIO-00.analog-stereo"
                  node.passive = true
              }
          }
      }
      ]
    '')
  ];

  # Fan control
  environment.etc."fan2go/fan2go.yaml".text = ''
    fans:
      - id: side
        hwmon:
          platform: nct6792-isa-0290
          index: 1
        neverStop: true
        minPwm: 80
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
        minPwm: 80
        curve: gpu_curve
        controlAlgorithm: direct
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
        pid:
          sensor: gpu_edge
          setPoint: 70
          p: -0.05
          i: -0.005
          d: -0.005
      - id: gpu_mem_curve
        pid:
          sensor: gpu_mem
          setPoint: 100
          p: -0.05
          i: -0.005
          d: -0.005
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

  # Make fish shell availlable
  programs.fish.enable = true;

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

  # syncthing
  services.syncthing = {
    enable = true;
    user = "maik";
  };

  # NixOS state version
  system.stateVersion = "24.05";
}
