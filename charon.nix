{
  pkgs,
  fetchpatch,
  ...
}: {
  imports = [
    ./_shared/common.nix
    ./hardware/charon.nix
    ./mounts/orpheus-nfs.nix
    ./services/audio-pipewire.nix
    ./services/chipcards.nix
    ./services/printing.nix
    ./services/scanning.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "charon";

  # Enable X13S support
  nixos-x13s = {
    enable = true;
    wifiMac = "F4:A8:0D:F5:5D:BC";
    bluetoothMac = "F4:A8:0D:30:9D:8B";
    kernel = "jhovold";
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Enable plymouth
  boot.plymouth = {
    enable = true;
    font = "${pkgs.inter}/share/fonts/truetype/InterVariable.ttf";
  };

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

  environment.etc."tmpfiles.d/home-maik.conf".text = ''
    d /home/maik               700 1000 100 -
  '';

  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

  # Use NetworkManager
  networking.networkmanager.enable = true;

  # https://github.com/jhovold/linux/wiki/X13s#modem
  networking.networkmanager.fccUnlockScripts = [
    {
      id = "105b:e0c3";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
    }
  ];

  # Disable NetworkManager wait online
  systemd.services."NetworkManager-wait-online".enable = false;

  # Enable mDNS
  services.avahi.enable = true;

  # Enable tailscale
  services.tailscale.enable = true;

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
    pkgs.widevine-overlay.widevine-cdm
    aspell
    aspellDicts.de
    aspellDicts.en
    celluloid
    firefox
    fractal
    fragments
    gitMinimal
    kodi
    libcamera
    libreoffice
    nfs-utils
    papers
    quodlibet
    resources
    tuba
    zed-editor
  ];

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

  # Enable TLP (and disable ppd)
  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;
  services.tlp.settings = {
    PCIE_ASPM_ON_BAT = "powersupersave";
    RUNTIME_PM_ON_AC = "auto";
    RUNTIME_PM_ON_BAT = "on";
    # Operation mode when no power supply can be detected: AC, BAT.
    TLP_DEFAULT_MODE = "BAT";
    # Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
    TLP_PERSISTENT_DEFAULT = "1";
    DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
    DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
    #
    START_CHARGE_THRESH_BAT0 = "75";
    STOP_CHARGE_THRESH_BAT0 = "80";
    #
    USB_AUTOSUSPEND = "1";
  };

  # Enable syncthing
  services.syncthing = {
    enable = true;
    user = "maik";
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

  system.stateVersion = "24.05";
}
