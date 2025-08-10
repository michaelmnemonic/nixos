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
    kdePackages.neochat
    kdePackages.qtlocation
    kdePackages.skanpage
    libcamera
    libreoffice-qt
    (pkgs.writeTextDir "share/sddm/themes/breeze/theme.conf.user" ''
      [General]
      background=${background-package}
    '')
    pinentry-qt
    syncthing
    transmission_4-qt
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
}
