{...}:{
  # Import modulesPath
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules to during initrd
  boot.initrd.availableKernelModules = [
    "nvme"
    "phy-qcom-qmp-pcie"
    "pcie-qcom"
  ];

  # Kernel modules to load ofter initrd
  boot.kernelModules = [];

  boot.initrd.kernelModules = [];
  boot.extraModulePackages = [];

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

  swapDevices = [];

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}