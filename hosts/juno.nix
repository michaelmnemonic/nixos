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
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
