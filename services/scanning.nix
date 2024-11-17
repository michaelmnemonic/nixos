{pkgs, ...}: {
  # Enable scanning
  hardware.sane = {
    enable = true;
    extraBackends = [pkgs.sane-airscan];
  };
  services.saned.enable = true;
}
