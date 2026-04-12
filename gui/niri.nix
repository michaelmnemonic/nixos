{
  pkgs,
  lib,
  ...
}: {
  # Make niri availlable
  programs.niri.enable = true;

  nixpkgs.config.qt5 = {
    enable = true;
    platformTheme = "qt5ct";
    style = {
      package = pkgs.adwaita-qt;
      name = "Adwaita";
    };
  };

  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    adwaita-qt
    aspell
    aspellDicts.de
    aspellDicts.en
    celluloid
    ddcutil
    firefox
    fractal
    fragments
    ghostty
    gitMinimal
    gnome-calculator
    gnome-calendar
    gnome-clocks
    gnome-text-editor
    keepassxc
    libreoffice
    libsForQt5.qt5ct
    mangohud
    nautilus
    nfs-utils
    papers
    pavucontrol
    quodlibet-full
    resources
    thunderbird
    tuba
    valent
    walker
    xwayland-satellite
  ];

  # Use qt5ct configuration
  environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";

  # Disable gnome-keyring, keepassxc is used instead
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  # Enable evolution
  programs.evolution.enable = true;

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

  services.gnome.evolution-data-server.enable = true;

  services.upower.enable = true;
}
