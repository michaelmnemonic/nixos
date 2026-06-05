{
  pkgs,
  lib,
  vibepanel,
  voxtype,
  ...
}: let
  patchedVibepanel = vibepanel.packages.${pkgs.system}.vibepanel.overrideAttrs (old: {
    patches = (old.patches or []) ++ [../patches/0001-vibepanel-voxtype-widget.patch];
  });
in {
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
    adwaita-fonts
    inter
    jetbrains-mono
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-color-emoji
  ];

  # List of system-wide packages
  environment.systemPackages =
    [
      patchedVibepanel
    ]
    ++ (with pkgs; [
      adwaita-icon-theme
      adwaita-qt
      aspell
      aspellDicts.de
      aspellDicts.en
      darktable
      ddcutil
      firefox
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
      loupe
      mangohud
      nautilus
      nfs-utils
      papers
      pavucontrol
      quodlibet-full
      resources
      tuba
      voxtype.packages.${pkgs.stdenv.hostPlatform.system}.onnx
      xdg-user-dirs
      xwayland-satellite
    ]);

  # Use qt5ct configuration
  environment.variables.QT_QPA_PLATFORMTHEME = "qt5ct";

  # Disable gnome-keyring, keepassxc is used instead
  services.gnome.gnome-keyring.enable = lib.mkForce false;

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  # Setup xdg
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

  # Enable battery state reporting
  services.upower.enable = true;

  # Start vibepanel as a systemd user service
  systemd.user.services.vibepanel = {
    description = "GTK4 panel for Wayland with notifications, OSD, and quick settings";
    after = ["graphical-session.target"];
    partOf = ["graphical-session.target"];
    requisite = ["graphical-session.target"];
    serviceConfig = {
      Slice = "session.slice";
      ExecStart = "${patchedVibepanel}/bin/vibepanel";
      Restart = "on-failure";
      RestartSec = "10";
    };
    wantedBy = ["graphical-session.target"];
  };
}
