{pkgs, ...}: {
  # Enable scanning
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
    openFirewall = true;
    netConf = "
10.0.0.1
192.168.178.30
    ";
  };
  services.saned.enable = true;
}
