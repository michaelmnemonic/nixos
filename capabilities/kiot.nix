{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.universe.kiot;
  kiotPackage = pkgs.kdePackages.callPackage ../pkgs/kiot {};
in {
  options.universe.kiot = {
    enable = lib.mkEnableOption "KDE Internet of Things desktop integration for home automation";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [kiotPackage];

    systemd.user.services.kiot = {
      description = "KDE Internet of Things daemon";
      wantedBy = ["graphical-session.target"];
      partOf = ["graphical-session.target"];
      serviceConfig = {
        ExecStart = "${kiotPackage}/bin/kiot";
        Restart = "on-failure";
        RestartSec = "5s";
        Slice = "background.slice";
      };
    };
  };
}
