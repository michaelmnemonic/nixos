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

  # Enable plymouth
  boot.plymouth.enable = true;

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  swapDevices = [];


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
