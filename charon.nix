{
  pkgs,
  lib,
  nixos-x13s,
  ...
}: {
  imports = [
    ./_shared/common.nix
    ./hardware/charon.nix
    ./services/audio.nix
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

  nixpkgs.config.allowUnfree = true;

  # Enable fingerprint reader
  services.fprintd.enable = true;

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Enable plymouth
  boot.plymouth.enable = true;

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
    enable = false;
  };

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
    aspell
    aspellDicts.de
    aspellDicts.en
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
    kdePackages.alpaka
    kdePackages.elisa
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    kdePackages.kio-extras
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

  # Enable TLP (and disable ppd)
  services.power-profiles-daemon.enable = false;
  powerManagement.powertop.enable = true;
  services.tlp.enable = true;
  services.tlp.settings = {
    PCIE_ASPM_ON_BAT = "powersupersave";
    RUNTIME_PM_ON_AC = "auto";
    # Operation mode when no power supply can be detected: AC, BAT.
    TLP_DEFAULT_MODE = "BAT";
    # Operation mode select: 0=depend on power source, 1=always use TLP_DEFAULT_MODE
    TLP_PERSISTENT_DEFAULT = "1";
    DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
    DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
    DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
  };

  system.stateVersion = "24.05";
}
