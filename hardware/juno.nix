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
  ];

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
      device = "/dev/disk/by-partlabel/SWAP";
    }
  ];

  boot.resumeDevice = "/dev/disk/by-partlabel/SWAP";

  # Enable rotation sensor
  hardware.sensor.iio.enable = true;

  # Enable power management
  powerManagement.enable = true;
  services.power-profiles-daemon.enable = true;

  # Suspend first then hibernate when closing the lid
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  # Hibernate on power button pressed
  services.logind.settings.Login.HandlePowerKey = "suspend-then-hibernate";

  # Define time delay for hibernation
  systemd.sleep.settings.Sleep = {
    HibernateDelaySec = "15m";
    SuspendState = "mem";
  };

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
