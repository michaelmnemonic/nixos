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

  # Set kernel parameters
  boot.kernelParams = [
    # https://wiki.debian.org/InstallingDebianOn/Thinkpad/X13s
    "iommu.passthrough=0"
    "iommu.strict=0"
    "pcie_aspm.policy=powersupersave"
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  # Enable X13S support
  nixos-x13s = {
    enable = true;
    wifiMac = "F4:A8:0D:F5:5D:BC";
    bluetoothMac = "F4:A8:0D:30:9D:8B";
    kernel = "jhovold";
  };

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}