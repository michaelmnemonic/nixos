{pkgs, ...}: {
  # Enable card reader
  services.pcscd = {
    enable = true;
    plugins = [
      pkgs.ccid
      pkgs.pcsc-cyberjack
    ];
  };
}
