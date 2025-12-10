{
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  # Import modulesPath
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules to during initrd
  boot.initrd.kernelModules = [
    # Early KMS to enable prettier boot *and* gpu overclock via tmpfile
    "amdgpu"
  ];

  # Kernel modules to load ofter initrd
  boot.kernelModules = [
    # Virtualization support
    "kvm-amd"
    # Motherboard sensors
    "nct6775"
  ];

  boot.extraModulePackages = [ ];

  boot.extraModprobeConfig = ''
    options ath12k_pci disable_aspm=1
  '';

  # Luks encrypted root partition
  boot.initrd.luks.devices.NIXOS = {
    device = "/dev/disk/by-partlabel/NIXOS";
    allowDiscards = true;
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

  swapDevices = [ ];

  # Kernel command line
  boot.kernelParams = [
    # Allow overclocking of GPU
    "amdgpu.ppfeaturemask=0xfff7ffff"
    # Use pstate_epp for CPU reclocking
    "amd_pstate=active"
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  # https://github.com/NixOS/nixpkgs/issues/466945
  hardware.firmware = [
    (pkgs.linux-firmware.overrideAttrs (old: {
      version = "3d5c8135206cef364e7d353711b3e7358a90d152";
      src = pkgs.fetchFromGitLab {
        owner = "kernel-firmware";
        repo = "linux-firmware";
        rev = "3d5c8135206cef364e7d353711b3e7358a90d152";
        hash = "sha256-ukXZjh5OWnFoppD1TVBwHvcXvH4IOoebnQI+pDm/nOk=";
      };
    }))
  ];

  # Make gpu acceleration availlable using rocm
  hardware.amdgpu.opencl.enable = true;
  hardware.graphics.extraPackages = with pkgs; [ rocmPackages.clr.icd ];

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
