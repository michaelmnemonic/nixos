{
  lib,
  modulesPath,
  nixos-x13s,
  ...
}: {
  # Import modulesPath
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules to during initrd
  boot.initrd.availableKernelModules = [
    "nvme"
    "phy-qcom-qmp-pcie"
    "pcie-qcom"

    "i2c-core"
    "i2c-hid"
    "i2c-hid-of"
    "i2c-qcom-geni"

    "leds_qcom_lpg"
    "pwm_bl"
    "qrtr"
    "pmic_glink_altmode"
    "gpio_sbu_mux"
    "phy-qcom-qmp-combo"
    "gpucc_sc8280xp"
    "dispcc_sc8280xp"
    "phy_qcom_edp"
    "panel-edp"
    "msm"
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

  # Set kernel parameters
  boot.kernelParams = [
    # https://wiki.debian.org/InstallingDebianOn/Thinkpad/X13s
    "iommu.passthrough=0"
    "iommu.strict=0"
    "pcie_aspm.policy=powersupersave"
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
