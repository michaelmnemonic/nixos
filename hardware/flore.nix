{
  lib,
  modulesPath,
  ...
}: {
  # Import modulesPath
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
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

  swapDevices = [];

  # Enable plymouth
  boot.plymouth.enable = true;

  # Enable power profile daemon
  services.power-profiles-daemon.enable = true;

  # Enable hardware accelerated graphics
  hardware.graphics.enable = true;

  # Host platform
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
