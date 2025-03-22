{
  pkgs,
  modulesPath,
  ...
}: {
  # Import modulesPath
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Kernel modules
  boot.kernelModules = [
    # Virtualization support
    "kvm-amd"
    # Motherboard sensors
    "nct6775"
  ];
  boot.extraModulePackages = [];

  # Luks encrypted root partition
  boot.initrd.luks.devices.NIXOS = {
    device = "/dev/disk/by-partlabel/NIXOS";
    allowDiscards = true;
  };

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

  # Kernel command line
  boot.kernelParams = [
    # Allow overclocking of GPU
    "amdgpu.ppfeaturemask=0xfff7ffff"
    # Use pstate_epp for CPU reclocking
    "amd_pstate=active"
  ];

  # Enable plymouth
  boot.plymouth.enable = true;

  # Make gpu acceleration availlable using rocm
  hardware.amdgpu.opencl.enable = true;
  hardware.graphics.extraPackages = with pkgs; [rocmPackages.clr.icd];

  # Host platform
  nixpkgs.hostPlatform = "x86_64-linux";
}
