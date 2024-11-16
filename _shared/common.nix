{...}: {
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

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Setup time zone
  time.timeZone = "Europe/Berlin";

  # Use german internationalisation
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # Enable sude for user of group wheel
  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Garbage collect nix store
  nix.settings.auto-optimise-store = true;
  nix.gc.automatic = true;
  nix.gc.options = "--delete-older-than 7d";

  # Never automatically reboot
  system.autoUpgrade.allowReboot = false;
}
