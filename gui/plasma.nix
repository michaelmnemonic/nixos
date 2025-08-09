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
    kdePackages.krdc
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.neochat
    kdePackages.qtlocation
    kdePackages.skanpage
    kdePackages.tokodon
    kmymoney
    libcamera
    libreoffice-qt
    (
      mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          dynamic-crop
          sponsorblock
        ];

        mpv = pkgs.mpv-unwrapped;
      }
    )
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
      });
    })
  ];
}
