{
  lib,
  modulesPath,
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

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
