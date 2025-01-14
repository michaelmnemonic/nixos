{pkgs, ...}: {
  imports = [
    ./_shared/common.nix
    ./hardware/charon.nix
    ./mounts/orpheus-nfs.nix
    ./services/audio-pulseaudio.nix
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
    #    wifiMac = true;
    #    bluetoothMac = true;
    kernel = "jhovold";
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Enable fingerprint reader
  services.fprintd.enable = true;

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

  # Use SDDM as displayManager
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
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
    pkgs.widevine-overlay.widevine-cdm
    aspell
    aspellDicts.de
    aspellDicts.en
    calibre
    digikam
    ffmpegthumbs
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
    kdePackages.elisa
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kio-extras
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.neochat
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    kmymoney
    libcamera
    libreoffice-qt
    mpv
    nfs-utils
    pinentry-qt
    syncthing
    transmission_4-qt
    unar
    zed-editor
  ];

  # Insecure dependency of neochat
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

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

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
  };

  # Enable ssh-agent
  programs.ssh = {
    startAgent = true;
    enableAskPassword = true;
    askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";
  };
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  system.stateVersion = "24.05";
}
