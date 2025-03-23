{pkgs, ...}: {
  # Deploy udev rules for steam
  hardware.steam-hardware.enable = true;

  # Make steam itself evaillable
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # prevent steam from asking for wifi passwords
    package = pkgs.steam.override {extraProfile = "export DBUS_SYSTEM_BUS_ADDRESS=";};
  };
}
