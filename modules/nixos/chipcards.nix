{pkgs, ...}: {
  # Enable card reader
  services.pcscd = {
    enable = true;
    plugins = [pkgs.pcsc-cyberjack];
  };
}
