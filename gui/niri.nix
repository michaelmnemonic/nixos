{pkgs, ...}: {
  # Make niri availlable
  programs.niri.enable = true;

  # Make waybar availlable
  programs.waybar.enable = true;

  # Networking with systemd-networkd and iwd
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."20-wlan" = {
    matchConfig.Name = "wlan*";
    networkConfig.DHCP = "yes";
  };
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };

  networking.wireless.iwd.enable = true;

  nixpkgs.config.qt5 = {
    enable = true;
    platformTheme = "qt5ct";
    style = {
      package = pkgs.adwaita-qt;
      name = "Adwaita";
    };
  };

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    alacritty
    aspell
    aspellDicts.de
    aspellDicts.en
    celluloid
    fan2go
    firefox
    fractal
    fragments
    fuzzel
    gitMinimal
    gnome-calculator
    gnome-clocks
    gnome-text-editor
    keepassxc
    adwaita-qt
    libsForQt5.qt5ct
    libreoffice
    playerctl
    mangohud
    mako
    mpv
    nautilus
    nfs-utils
    papers
    pavucontrol
    ptyxis
    quodlibet-full
    resources
    swaylock
    thunderbird
    tuba
    valent
    vscodium
    xwayland-satellite
    wineWowPackages.stable
    zed-editor
  ];

  # Use qt5ct configuration
  environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";

  # Disable gnome-keyring, keepassxc is used instead
  services.gnome.gnome-keyring.enable = false;

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  xdg = {
    autostart.enable = true;
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome];
    };
  };

  # Enable dbus with "dbus-broker" implementation
  services.dbus = {
    enable = true;
    implementation = "broker";
  };
}
