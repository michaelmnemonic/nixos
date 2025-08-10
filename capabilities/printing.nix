{pkgs, ...}: {
  # Enable printing
  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };
}
