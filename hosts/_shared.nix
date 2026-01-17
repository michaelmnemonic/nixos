{
  pkgs,
  config,
  ...
}: {
  # Initrd configuration
  boot.initrd.systemd.enable = true;
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
  ];
  boot.initrd.kernelModules = [];

  # Supress log messages
  boot.consoleLogLevel = 0;

  # Boot loader
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      editor = false;
      enable = true;
      configurationLimit = 5;
    };
    timeout = 0;
  };

  # Kernel command line
  boot.kernelParams = [
    "quiet"
    "loglevel=0"
    "systemd.show_status=false"
    "vt.global_cursor_default=0"
  ];

  # Setup time zone
  time.timeZone = "Europe/Berlin";

  # Hard-code host entries
  networking.extraHosts = ''
    192.168.178.30 orpheus
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
      what = "orpheus:";
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
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Garbage collect nix store
  nix.settings = {
    auto-optimise-store = true;
  };

  programs.git = {
    enable = true;
    lfs.enable = true;
  };

  nix = {
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
    settings = {
      substituters = [
        "https://cache.nixos.org/"
        "https://michaelmnemonic.cachix.org"
      ];
      trusted-public-keys = [
        "michaelmnemonic.cachix.org-1:uzb3NmZbeqWe1iNTh9llun7QhGzzmYncoSsk+jczbPM="
      ];
    };
  };

  # Enable auto upgrades, but without automatic reboot
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
    flake = "github:michaelmnemonic/nixos/niri-on-charon";
  };
}
