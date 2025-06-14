{pkgs, ...}: {
  # Use GNOME as desktop environment
  services.xserver.desktopManager.gnome.enable = true;

  # Debloat GNOME install
  environment.gnome.excludePackages = with pkgs; [
    gnome-tour
    gnome-music
    gnome-system-monitor
    epiphany
    evince
  ];

  # No need for xterm
  services.xserver.excludePackages = [pkgs.xterm];
  services.xserver.desktopManager.xterm.enable = false;

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    celluloid
    foliate
    gnomeExtensions.caffeine
    libcamera
    papers
    quodlibet
    resources
    syncthing
    tuba
  ];

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
    package = pkgs.gnomeExtensions.gsconnect;
  };

  # Enable dbus with "dbus-broker" implementation
  services.dbus = {
    enable = true;
    implementation = "broker";
  };
}
