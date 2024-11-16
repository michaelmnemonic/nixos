{pkgs, ...}: {
  # enable card reader
  services.pcscd = {
    enable = true;
    plugins = [pkgs.pcsc-cyberjack];
  };
}
