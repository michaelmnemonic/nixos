{
  inputs,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/juno.nix
    # Users
    ../users/maik.nix
    # Audio and video via pipwire
    ../capabilities/pipewire.nix
    # Chipcards via pcscd
    ../capabilities/chipcards.nix
    # Printing
    ../capabilities/printing.nix
    # Scanning
    ../capabilities/scanning.nix
    # VS Code
    ../capabilities/vscode.nix
    # Wireguard
    ../capabilities/wireguard.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Network configuration
  networking.hostName = "juno";
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

  # Use GNOME as desktop environment
  services.xserver.desktopManager.gnome.enable = true;

  # Use GDM as displayManager
  services.xserver.displayManager.gdm.enable = true;

  # Debloat GNOME install
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    gnome-system-monitor
    epiphany
    evince
    flashrom
  ];

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # Add inter, jetbrains-mono and noto fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # Enable auto rotation
  hardware.sensor.iio.enable = true;

  # Enable fscrypt
  security.pam.enableFscrypt = true;

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    celluloid
    firefox
    gnomeExtensions.caffeine
    kodi
    libcamera
    nfs-utils
    papers
    quodlibet
    resources
    syncthing
    tuba
    foliate
  ];

  #####################
  # ETC configuration #
  #####################

  # Optimize power consumption
  environment.etc."tmpfiles.d/optimize-power-consumption.conf".text = ''
    w /sys/class/net/wlp0s20f3/device/power/wakeup    - - - - disabled
    w /sys/bus/usb/devices/1-3.2/power/wakeup         - - - - disabled
    w /sys/bus/usb/devices/usb1/power/wakeup          - - - - disabled
    w /sys/bus/usb/devices/1-10/power/wakeup          - - - - disabled
    w /sys/bus/usb/devices/1-3/power/wakeup           - - - - disabled
    w /sys/bus/usb/devices/usb2/power/wakeup          - - - - disabled
    w /sys/bus/usb/devices/1-6/power/wakeup           - - - - disabled
    w /sys/bus/usb/devices/1-2.2.3/power/control      - - - - auto
    w /sys/bus/usb/devices/1-2.2.4/power/control      - - - - auto
    w /proc/sys/vm/dirty_writeback_centisecs          - - - - 1500
    w /sys/module/snd_hda_intel/parameters/power_save - - - - 1
    w /proc/sys/kernel/nmi_watchdog                   - - - - 0
    w /sys/bus/pci/devices/0000:01:00.0/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:0a.0/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:14.2/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:00.0/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:1f.5/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:14.3/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:1f.0/power/control - - - - auto
    w /sys/bus/pci/devices/0000:00:08.0/power/control - - - - auto
    w /proc/acpi/wakeup                               - - - - CNVW
    w /proc/acpi/wakeup                               - - - - XHCI
  '';

  # Run powertop auto tune on startup
  powerManagement.powertop.enable = true;

  services.pipewire.configPackages = [
    # Provide equalizer for StarLabs Star Lite Mk V speaker
    (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-starlabs-star-lite-mk-v.conf" ''
        context.modules = [
          { name = libpipewire-module-filter-chain
            args = {
              node.description = "Lautsprecher"
              media.name       = "Lautsprecher"
              filter.graph = {
                  nodes = [
                      {
                          type  = builtin
                          name  = eq_band_1
                          label = bq_peaking
                          control = { "Freq" = 479 "Q" = 1.0 "Gain" = 6.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_2
                          label = bq_peaking
                          control = { "Freq" = 531 "Q" = 1.0 "Gain" = 7.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_3
                          label = bq_peaking
                          control = { "Freq" = 566 "Q" = 5.72 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_4
                          label = bq_peaking
                          control = { "Freq" = 583 "Q" = 1.73 "Gain" = -31.3 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_5
                          label = bq_peaking
                          control = { "Freq" = 696 "Q" = 1.24 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_6
                          label = bq_peaking
                          control = { "Freq" = 800 "Q" = 5.0 "Gain" = -2.3 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_7
                          label = bq_peaking
                          control = { "Freq" = 882 "Q" = 3.21 "Gain" = -12.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_8
                          label = bq_peaking
                          control = { "Freq" = 1164 "Q" = 3.66 "Gain" = -6.7 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_9
                          label = bq_peaking
                          control = { "Freq" = 1317 "Q" = 7.48 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_10
                          label = bq_peaking
                          control = { "Freq" = 1397 "Q" = 4.96 "Gain" = -6.6 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_11
                          label = bq_peaking
                          control = { "Freq" = 1645 "Q" = 4.59 "Gain" = -7.3 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_12
                          label = bq_peaking
                          control = { "Freq" = 1670 "Q" = 7.35 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_13
                          label = bq_peaking
                          control = { "Freq" = 2258 "Q" = 4.34 "Gain" = 1.7 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_14
                          label = bq_peaking
                          control = { "Freq" = 2403 "Q" = 1.0 "Gain" = 7.5 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_15
                          label = bq_peaking
                          control = { "Freq" = 2403 "Q" = 2.56 "Gain" = -11.7 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_16
                          label = bq_peaking
                          control = { "Freq" = 3157 "Q" = 1.87 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_17
                          label = bq_peaking
                          control = { "Freq" = 3266 "Q" = 4.64 "Gain" = -8.7 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_18
                          label = bq_peaking
                          control = { "Freq" = 4060 "Q" = 1.86 "Gain" = -10.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_19
                          label = bq_peaking
                          control = { "Freq" = 4658 "Q" = 2.72 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_20
                          label = bq_peaking
                          control = { "Freq" = 5174 "Q" = 4.82 "Gain" = -9.1 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_21
                          label = bq_peaking
                          control = { "Freq" = 6704 "Q" = 2.62 "Gain" = 5.4 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_22
                          label = bq_peaking
                          control = { "Freq" = 6765 "Q" = 1.99 "Gain" = 9.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_23
                          label = bq_peaking
                          control = { "Freq" = 6873 "Q" = 1.15 "Gain" = -25.0 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_24
                          label = bq_peaking
                          control = { "Freq" = 7234 "Q" = 2.88 "Gain" = -8.9 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_25
                          label = bq_peaking
                          control = { "Freq" = 14362 "Q" = 3.77"Gain" = -7.4 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_26
                          label = bq_peaking
                          control = { "Freq" = 15258 "Q" = 1.0 "Gain" = 2.3 }
                      }
                      {
                          type  = builtin
                          name  = eq_band_27
                          label = bq_peaking
                          control = { "Freq" = 16182 "Q" = 1.62 "Gain" = 2.2 }
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
                      { output = "eq_band_14:Out" input = "eq_band_15:In" }
                      { output = "eq_band_15:Out" input = "eq_band_16:In" }
                      { output = "eq_band_16:Out" input = "eq_band_17:In" }
                      { output = "eq_band_17:Out" input = "eq_band_18:In" }
                      { output = "eq_band_18:Out" input = "eq_band_19:In" }
                      { output = "eq_band_19:Out" input = "eq_band_20:In" }
                      { output = "eq_band_20:Out" input = "eq_band_21:In" }
                      { output = "eq_band_21:Out" input = "eq_band_22:In" }
                      { output = "eq_band_22:Out" input = "eq_band_23:In" }
                      { output = "eq_band_23:Out" input = "eq_band_24:In" }
                      { output = "eq_band_24:Out" input = "eq_band_25:In" }
                      { output = "eq_band_25:Out" input = "eq_band_26:In" }
                      { output = "eq_band_26:Out" input = "eq_band_27:In" }
                  ]
              }
          audio.channels = 2
          audio.position = [ FL FR ]
              capture.props = {
                  node.name   = "effect_input.eq27"
                  media.class = Audio/Sink
              }
              playback.props = {
                  node.name   = "effect_output.eq27"
                  node.target = "alsa_output.pci-0000_00_1f.3.analog-stereo"
                  node.passive = true
              }
          }
        }
      ]
    '')
  ];
  ############
  # Programs #
  ############

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  # Enable ssh-agent
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
  };

  # Enable gnupg
  programs.gnupg.agent = {
    enable = true;
  };

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

  # Enable fwupd
  services.fwupd.enable = true;

  # NixOS state version
  system.stateVersion = "24.05";
}
