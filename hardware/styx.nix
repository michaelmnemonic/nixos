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
  boot.initrd.kernelModules = [
  ];

  # Kernel modules to load ofter initrd
  boot.kernelModules = [
  ];

  boot.extraModulePackages = [];

  boot.extraModprobeConfig = ''
  '';

  # Luks encrypted root partition
  boot.initrd.luks.devices.NIXOS = {
    device = "/dev/disk/by-partlabel/NIXOS";
    allowDiscards = true;
    crypttabExtraOpts = [];
  };

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "subvol=@"
      "compress=zstd:1"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/SWAP";
      randomEncryption.enable = true;
    }
  ];

  boot.zswap = {
    enable = true;
    compressor = "lz4hc";
  };

  # Kernel command line
  boot.kernelParams = [
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  # GPU
  hardware.intelgpu = {
    driver = lib.mkIf (lib.versionAtLeast config.boot.kernelPackages.kernel.version "6.8") "xe";
    vaapiDriver = "intel-media-driver";
  };

  # Update microcode
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
