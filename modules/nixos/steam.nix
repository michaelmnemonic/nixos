{
  pkgs,
  lib,
  ...
}: {
  # Deploy udev rules for steam
  hardware.steam-hardware.enable = true;

  # Make steam itself evaillable
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # prevent steam to access wifi passwords
    package = pkgs.steam.override {extraProfile = "export DBUS_SYSTEM_BUS_ADDRESS=";};
  };

  # Steam is not free software
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
    ];
}
