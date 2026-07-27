{pkgs, ...}: let
  background-package = pkgs.stdenvNoCC.mkDerivation {
    name = "background-image";
    src = ./.;
    dontUnpack = true;
    installPhase = ''
      cp $src/wallpaper.jpg $out
    '';
  };
in {
  # Use plasma as desktop environment
  services.desktopManager.plasma6.enable = true;

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # Exclude some default packages
  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    discover
    kwin-x11
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    kdePackages.ark
    kdePackages.ffmpegthumbs
    kdePackages.kcalc
    kdePackages.kio-extras
    kdePackages.krdc
    kdePackages.ksshaskpass
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.wacomtablet
    libcamera
    libreoffice-qt
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${background-package}
    '')
    unar
  ];

  # kdePackages.neochat has known vulns in depedency
  nixpkgs.config.permittedInsecurePackages = [
    "olm-3.2.16"
  ];

  # Make ssh-askpass prefer to interactivly ask for password
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  # Enable dbus with "dbus-broker" implementation
  services.dbus = {
    enable = true;
    implementation = "broker";
  };

  # Enable firefox
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = [pkgs.kdePackages.plasma-browser-integration];
  };

  # Enable kdeconnect
  programs.kdeconnect.enable = true;

  # Use ksshaskpass for ssh
  programs.ssh.askPassword = "${pkgs.kdePackages.ksshaskpass}/bin/ksshaskpass";

  # Run speech-dispatcher in the background slice to reduce resource contention
  systemd.user.services.speech-dispatcher = {
    serviceConfig.Slice = "background.slice";
  };

  # Run kdeconnect daemon in the background slice to reduce resource contention
  systemd.user.services."app-org.kde.kdeconnect.daemon@autostart.service" = {
    serviceConfig.Slice = "background.slice";
  };

  # Run dconf in the background slice to reduce resource contention
  systemd.user.services.dconf = {
    serviceConfig.Slice = "background.slice";
  };

  # Run geoclue-agent in the background slice to reduce resource contention
  systemd.user.services.geoclue-agent = {
    serviceConfig.Slice = "background.slice";
  };

  # Run xdg-desktop-portal-gtk in the background slice to reduce resource contention
  systemd.user.services.xdg-desktop-portal-gtk = {
    serviceConfig.Slice = "background.slice";
  };

  # Run obex in the background slice to reduce resource contention
  systemd.user.services.obex = {
    serviceConfig.Slice = "background.slice";
  };

  # Run kalendarac in the background slice to reduce resource contention
  systemd.user.services."app-org.kde.kalendarac@autostart" = {
    serviceConfig.Slice = "background.slice";
  };
}
