{pkgs, ...}: {
  # Make fan2go an lm_sensors availlable
  environment.systemPackages = with pkgs; [
    fan2go
    lm_sensors
  ];

  # Systemd service
  systemd.services.fan2go = {
    enable = true;
    after = ["lm-sensors.service"];
    description = "Advanced Fan Control program";
    path = [pkgs.procps];
    serviceConfig = {
      Type = "simple";
      Restart = "always";
      RestartSec = "1s";
      ExecStart = ''${pkgs.fan2go}/bin/fan2go -c /etc/fan2go/fan2go.yaml --no-style'';
    };
    wantedBy = ["multi-user.target"];
  };
}
