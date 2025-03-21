{pkgs, ...}: {
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
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = ["JetBrains Mono"];
    sansSerif = ["Inter"];
  };

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    alacritty
    aspell
    aspellDicts.de
    aspellDicts.en
    audacious
    brightnessctl
    firefox
    fooyin
    fuzzel
    gitMinimal
    iosevka
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
    pavucontrol
    pinentry-qt
    ptyxis
    quodlibet-full
    resources
    syncthing
    teams-for-linux
    transmission_4-qt
    unar
    vscodium
    yt-dlp
    zed-editor
  ];

  # Make vscode use wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

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

  # Make direnv availlable
  programs.direnv.enable = true;

  programs.dconf.enable = true;

  # Make fish shell availlable
  programs.fish.enable = true;

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
  };

  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [nvim-lspconfig];
      };
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
