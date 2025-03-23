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
    hosts-charon
    # Users
    users-maik
    # Audio and video via pipwire
    pipewire
    # Printing
    printing
    # Scanning
    scanning
  ];

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Network configuration
  networking.hostName = "charon";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;
  networking.modemmanager.fccUnlockScripts = [
    {
      id = "105b:e0c3";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
    }
  ];

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

  # Use sddm as display-manager
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };
  };

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

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
    aspell
    aspellDicts.de
    aspellDicts.en
    firefox
    fooyin
    gitMinimal
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-search
    kdePackages.akregator
    kdePackages.alligator
    kdePackages.arianna
    kdePackages.elisa
    kdePackages.ffmpegthumbs
    kdePackages.ghostwriter
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kio-extras
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.marknote
    kdePackages.merkuro
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    kmymoney
    libcamera
    libreoffice-qt
    mpv
    nautilus
    nfs-utils
    pinentry-qt
    syncthing
    transmission_4-qt
    unar
    vscodium
    yt-dlp
    zed-editor
  ];

  #########################
  # Environment variables #
  #########################

  # VSCode shall use native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Make ssh-askpass prefer to interactivly ask for password
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  # Make fish shell availlable
  programs.fish.enable = true;

  # Enable kdeconnect
  programs.kdeconnect.enable = true;

  # Enable ssh-agent
  programs.ssh = {
    startAgent = true;
    askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
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

  # Enable gnupg
  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-qt;
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
