{pkgs, config, ...}: {
  # Initrd configuration
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci"];
  boot.initrd.kernelModules = [];

  # Supress log messages
  boot.consoleLogLevel = 0;

  # Boot loader
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.editor = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 0;

  # Kernel command line
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "systemd.show_status=false"
    "vt.global_cursor_default=0"
  ];

  # Setup time zone
  time.timeZone = "Europe/Berlin";

  # Disable ttys
  services.logind.extraConfig = ''
    NAutoVTs=0
    ReserveVT=0
  '';

  # Use german internationalisation
  i18n.defaultLocale = "de_DE.UTF-8";
  console.keyMap = "de";

  # Use german keyboard layout
  services.xserver = {
    enable = true;
    # set keymap
    xkb.layout = "de";
  };

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Make users immutable
  users.mutableUsers = false;

  # Enable sudo for user of group wheel
  security.sudo.enable = true;
  security.sudo.execWheelOnly = true;

  # Enable fscrypted home directories
  security.pam.enableFscrypt = true;

  # Auto mount orpheus:
  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
        ForceUnmount = true;
        TimeoutSec = "5s";
      };
      what = "192.168.178.30:";
      where = "/mnt";
    }
  ];
  systemd.automounts = [
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt";
    }
  ];

  # Minimal set of packages
  environment.systemPackages = with pkgs; [
    gitMinimal
    nfs-utils
  ];

  # Enable direnv
  programs.direnv.enable = true;

  # Enable flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # Garbage collect nix store
  nix.settings = {
    substituters = [ "@nix-cache-host@" ];
    trusted-public-keys = [ "@nix-cache-host-key@" ];
    secret-key-files = [ "@nix-cache-host-private-key@" ];
    auto-optimise-store = true;
  };

  system.activationScripts."nix-cache-host" = ''
    secret=$(cat "${config.age.secrets.nix-cache-host.path}")
    configFile=/etc/nix/nix.conf
    ${pkgs.gnused}/bin/sed -i "s#@nix-cache-host@#$secret#" "$configFile"
  '';

  system.activationScripts."nix-cache-host-key" = ''
    secret=$(cat "${config.age.secrets.nix-cache-host-key.path}")
    configFile=/etc/nix/nix.conf
    ${pkgs.gnused}/bin/sed -i "s#@nix-cache-host-key@#$secret#" "$configFile"
  '';

  system.activationScripts."nix-cache-host-private-key" = ''
    secret=$(cat "${config.age.secrets.nix-cache-host-private-key.path}")
    configFile=/etc/nix/nix.conf
    ${pkgs.gnused}/bin/sed -i "s#@nix-cache-host-private-key@#$secret#" "$configFile"
  '';

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 7d";
  };

  # Enable auto upgrades, but without automatic reboot
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "github:michaelmnemonic/nixos";
  };
}
