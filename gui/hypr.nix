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
    adwaita-qt
    alacritty
    aspell
    aspellDicts.de
    aspellDicts.en
    brightnessctl
    blueberry
    celluloid
    fan2go
    firefox
    fractal
    file-roller
    fragments
    fuzzel
    gitMinimal
    gnome-calculator
    gnome-clocks
    gnome-text-editor
    hyprlock
    hyprpaper
    keepassxc
    libreoffice
    libsForQt5.qt5ct
    mako
    mangohud
    nautilus
    newsflash
    nfs-utils
    papers
    pavucontrol
    playerctl
    ptyxis
    quodlibet-full
    resources
    rose-pine-hyprcursor
    swayosd
    thunderbird
    tuba
    valent
    walker
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

  # swayosd
  systemd.services.swayosd-libinput-backend = {
    description = "SwayOSD LibInput backend for listening to certain keys like CapsLock, ScrollLock, VolumeUp, etc.";
    documentation = [ "https://github.com/ErikReider/SwayOSD" ];
    wantedBy = [ "graphical.target" ];
    partOf = [ "graphical.target" ];
    after = [ "graphical.target" ];

    serviceConfig = {
      Type = "dbus";
      BusName = "org.erikreider.swayosd";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-libinput-backend";
      Restart = "on-failure";
    };
  };

  systemd.user.services.swayosd-server = {
    description = "SwayOSD server";
    documentation = [ "https://github.com/ErikReider/SwayOSD" ];
    after = [ "graphical-session.target" ];

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.swayosd}/bin/swayosd-server";
      Restart = "on-failure";
    };
  };
}
