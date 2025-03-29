{pkgs, ...}: {
  # Use plasma as desktop environment
  services.desktopManager.plasma6.enable = true;

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    aqbanking
    aspell
    aspellDicts.de
    aspellDicts.en
    fooyin
    haruna
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-search
    kdePackages.ark
    kdePackages.ffmpegthumbs
    kdePackages.kcalc
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kio-extras
    kdePackages.kleopatra
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    kmymoney
    libcamera
    libreoffice-qt
    mpv
    pinentry-qt
    transmission_4-qt
    unar
  ];

  # Make ssh-askpass prefer to interactivly ask for password
  environment.sessionVariables.SSH_ASKPASS_REQUIRE = "prefer";

  # Enable XDG portals
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      kdePackages.xdg-desktop-portal-kde
    ];
  };

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

  # Customize kde plasma
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (sfinal: sprev: {
        # https://invent.kde.org/plasma/ksshaskpass/-/merge_requests/24
        ksshaskpass = sprev.ksshaskpass.overrideAttrs (oldAttrs: {
          patches = builtins.fetchurl {
            url = "https://invent.kde.org/plasma/ksshaskpass/-/merge_requests/24.patch";
            sha256 = "sha256:00rqh4bkwy8hhh2fl3pqddilprilanp78zi2l84ggfik4arm52ig";
          };
        });
        # smaller systemtray icons with more spacing
        # FIXME: this compiles plasma-workspace just to patch qml script
        plasma-workspace = sprev.plasma-workspace.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches
            ++ [
              ../patches/0001-plasma-workspaces-systemtray-icon-sizes.patch
              ../patches/0002-plasma-workspaces-lockout-icon-sizes.patch
            ];
          });
      });
    })
  ];


}
