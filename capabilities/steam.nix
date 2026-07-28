{pkgs, ...}: {
  # Deploy udev rules for steam
  hardware.steam-hardware.enable = true;

  # Make steam itself evaillable
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  };
}
