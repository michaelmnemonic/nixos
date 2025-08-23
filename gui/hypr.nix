{pkgs, ...}:{
  # make hyprland enable
  programs.hyprland = {
    enable = true;
    withUWSM  = true;
  };

  # Make waybar availlable
  programs.waybar.enable = true;

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    adwaita-icon-theme
    alacritty
    aspell
    aspellDicts.de
    aspellDicts.en
    brightnessctl
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
    nautilus
    nfs-utils
    papers
    pavucontrol
    hyprpaper
    ptyxis
    rose-pine-hyprcursor
    quodlibet-full
    resources
    thunderbird
    tuba
    valent
  ];

  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # Disable gnome-keyring, keepassxc is used instead
  services.gnome.gnome-keyring.enable = false;

  # Enable blueman bluetooth manager
  services.blueman.enable = true;

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  xdg = {
    autostart.enable = true;
    menus.enable = true;
    mime.enable = true;
    icons.enable = true;
    portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    };
  };

  # Enable dbus with "dbus-broker" implementation
  services.dbus = {
    enable = true;
    implementation = "broker";
  };
}
