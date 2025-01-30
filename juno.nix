{
  lib,
  pkgs,
  ...
}: {
  imports = [
    ./_shared/common.nix
    ./hardware/juno.nix
    ./mounts/orpheus-nfs.nix
    ./programs/direnv.nix
    ./services/audio-pipewire.nix
    ./services/chipcards.nix
    ./services/printing.nix
    ./services/scanning.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "juno";

  # Set kernel parameters
  boot.kernelParams = [
    # Disable mitigiations for some extra performance
    "mitigations=off"
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable TLP (and disable ppd)
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings = {
    # Use scedutil in all cases
    CPU_SCALING_GOVERNOR_ON_AC = "schedutil";
    CPU_SCALING_GOVERNOR_ON_BAT = "schedutil";
    # Set PCIE powersaving
    PCIE_ASPM_ON_BAT = "powersupersave";
    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "on";
    # Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
    TLP_PERSISTENT_DEFAULT = "1";
    DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
    DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
    # Enable USB autosuspend
    USB_AUTOSUSPEND = "1";
    CPU_MIN_PERF_ON_AC = "0";
    CPU_MAX_PERF_ON_AC = "100";
    CPU_MIN_PERF_ON_BAT = "0";
    CPU_MAX_PERF_ON_BAT = "75";
    CPU_HWP_DYN_BOOST_ON_AC = "1";
    CPU_HWP_DYN_BOOST_ON_BAT = "1";
    CPU_BOOST_ON_AC = "1";
    CPU_BOOST_ON_BAT = "1";


  };


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

  # Enable plymouth
  boot.plymouth.enable = true;

  # Enable bluetooth
  hardware.bluetooth.enable = true;

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

  # Use GNOME as desktop environment
  services.xserver.desktopManager.gnome.enable = true;

  # Use GDM as displayManager
  services.xserver.displayManager.gdm.enable = true;

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # Enable auto rotation
  hardware.sensor.iio.enable = true;

  # Enable hardware accelerated video decode
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Use NetworkManager
  networking.networkmanager.enable = true;

  # Enable tailscale
  services.tailscale.enable = true;

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

  # Debloat GNOME install
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    gnome-system-monitor
    epiphany
    evince
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    celluloid
    firefox
    libcamera
    quodlibet
    nfs-utils
    papers
    resources
    syncthing
    tuba
    kodi
  ];

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

  # Enable GnuPG
  programs.gnupg.agent = {
    enable = true;
  };

  # Enable auto upgrades, but without automatic reboot
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "github:michaelmnemonic/nixos";
  };

  system.stateVersion = "24.05";
}
