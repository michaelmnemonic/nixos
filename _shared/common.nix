{
  pkgs,
  lib,
  ...
}: {
  # Use systemd-boot as EFI boot loader.
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;

  # Enable systemd-based initrd
  boot.initrd.systemd.enable = true;

  # Suppress boot messages
  boot.consoleLogLevel = 0;
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "vt.global_cursor_default=0"
  ];
}
