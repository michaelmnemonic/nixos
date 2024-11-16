{
  lib,
  pkgs,
  ...
}: {
  hardware.steam-hardware.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    # prevent steam to access wifi passwords
    package = pkgs.steam.override {extraProfile = "export DBUS_SYSTEM_BUS_ADDRESS=";};
  };
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
      "steam-original"
      "steam-unwrapped"
      "steam-run"
    ];
}
