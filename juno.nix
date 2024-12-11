{
  lib,
  pkgs,
  autotag,
  ...
}: {
  imports = [
    ./_shared/common.nix
    ./hardware/pluto.nix
    ./mounts/orpheus-nfs.nix
    ./programs/direnv.nix
    ./services/audio.nix
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
    # Enable hibernate
    "resume=LABEL=SWAP"
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Enable plymouth
  boot.plymouth.enable = true;

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

  # Enable hibernate
  systemd.sleep.extraConfig = ''
    AllowSuspend=yes
    AllowHibernation=yes
    AllowHybridSleep=no
    AllowSuspendThenHibernate=yes
    HibernateDelaySec=15m
    SuspendState=mem
    MemorySleepMode=deep
  '';

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
    nfs-utils
    papers
    resources
    syncthing
    tuba
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

  system.stateVersion = "24.05";
}
