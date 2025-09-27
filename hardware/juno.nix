{
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  # Import modulesPath
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules to during initrd
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
  ];

  # Kernel modules to load ofter initrd
  boot.kernelModules = ["kvm-intel"];

  boot.initrd.kernelModules = [];
  boot.extraModulePackages = [];

  # Set kernel parameters
  boot.kernelParams = [
    # Allow firmware upgrades
    "iomem=relaxed"
    # Allow hibernate
    "resume=/dev/disk/by-label/NIXOS"
    "resume_offset=1229312"
    "mem_sleep_default=deep"
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "f2fs";
    options = ["compress_algorithm=zstd:1" "compress_chksum" "atgc" "gc_merge" "lazytime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 20 * 1024; # 32GB in MB
    }
  ];

  boot.resumeDevice = "/dev/disk/by-label/NIXOS";

  powerManagement.enable = true;

  services.power-profiles-daemon.enable = true;
  # Suspend first then hibernate when closing the lid
  services.logind.lidSwitch = "suspend-then-hibernate";
  # Hibernate on power button pressed
  services.logind.powerKey = "hibernate";

  # Define time delay for hibernation
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15m
    SuspendState=mem
  '';

  # Enable hardware accelerated video decode
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
    ];
  };

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
