{pkgs, nixos-x13s, ...}: {
  imports = [
    ./_shared/common.nix
    ./hardware/charon.nix
    ./mounts/orpheus-webdav.nix
    ./services/audio-pipewire.nix
    ./services/chipcards.nix
    ./services/printing.nix
    ./services/scanning.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "charon";

  # Set kernel parameters
  boot.kernelParams = [
    # https://wiki.debian.org/InstallingDebianOn/Thinkpad/X13s
    "iommu.passthrough=0"
    "iommu.strict=0"
    "pcie_aspm.policy=powersupersave"
  ];

  # Enable X13S support
  nixos-x13s = {
    enable = true;
    wifiMac = "F4:A8:0D:F5:5D:BC";
    bluetoothMac = "F4:A8:0D:30:9D:8B";
    kernel = "mainline";
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

  # Use plasma as desktop environment
  services.desktopManager.plasma6.enable = true;

  # Auto log-in with greetd
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

  # make sure syncthing home exists
  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

  # customize the desktop
  # FIXME: this compiles plasma-workspace just to patch qml script
  #   nixpkgs.overlays = [
  #     (final: prev: {
  #       # use smaller icons with more spacing in plasma-workspace
  #       kdePackages = prev.kdePackages.overrideScope (sfinal: sprev: {
  #         plasma-workspace = sprev.plasma-workspace.overrideAttrs (oldAttrs: {
  #           patches =
  #             oldAttrs.patches
  #             ++ [
  #               ./patches/0001-plasma-workspaces-systemtray-icon-sizes.patch
  #               ./patches/0002-plasma-workspaces-lockout-icon-sizes.patch
  #             ];
  #         });
  #       });
  #     })
  #   ];

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

  # Use NetworkManager
  networking.networkmanager.enable = true;

  # https://github.com/jhovold/linux/wiki/X13s#modem
  networking.modemmanager.fccUnlockScripts = [
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

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    arianna
    aspell
    aspellDicts.de
    aspellDicts.en
    calibre
    chromium
    digikam
    ffmpegthumbs
    fooyin
    gitMinimal
    iosevka
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-search
    kdePackages.akregator
    kdePackages.alligator
    kdePackages.elisa
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
    kmymoney
    libcamera
    libreoffice-qt
    mpv
    yt-dlp
    nfs-utils
    pinentry-qt
    syncthing
    teams-for-linux
    transmission_4-qt
    unar
    zed-editor
  ];

  # Enable syncthing
  services.syncthing = {
    enable = true;
    user = "maik";
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
    # Operation mode when no power supply can be detected: AC, BAT.
    TLP_DEFAULT_MODE = "BAT";
    # Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
    TLP_PERSISTENT_DEFAULT = "1";
    DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
    DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
    # Enable USB autosuspend
    USB_AUTOSUSPEND = "1";
  };

  # Make fish shell availlable
  programs.fish.enable = true;

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
  };

  programs.firefox = {
    enable = true;
    languagePacks = ["de"];
    nativeMessagingHosts.packages = [pkgs.ff2mpv];
    preferences = {
      "browser.download.alwaysOpenPanel" = false;
      "widget.use-xdg-desktop-portal.file-picker" = 1;
    };
  };

  # Enable ssh-agent
  programs.ssh = {
    startAgent = true;
    askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  };
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  system.stateVersion = "24.05";
}
