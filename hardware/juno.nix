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
    # touchscreen
    "hid"
    "hid_generic"
    "hid_multitouch"
    "intel_lpss_pci"
  ];

  # Kernel modules to load ofter initrd
  boot.kernelModules = ["kvm-intel"];

  boot.initrd.kernelModules = [];
  boot.extraModulePackages = [];

  # Set kernel parameters
  boot.kernelParams = [
    # Allow firmware upgrades
    "iomem=relaxed"
    # Allow hibernate
    "resume=/dev/disk/by-label/SWAP"
    #"resume_offset=369152"
    "mem_sleep_default=deep"
  ];

  # Luks devices
  boot.initrd.luks.devices = {
    NIXOS = {
      device = "/dev/disk/by-partlabel/NIXOS";
      allowDiscards = true;
      crypttabExtraOpts = ["fido2-device=auto"];
    };
    SWAP = {
      device = "/dev/disk/by-partlabel/SWAP";
      allowDiscards = true;
      crypttabExtraOpts = ["fido2-device=auto"];
    };
  };

  # Filesystems
  fileSystems."/" = {
    device = "/dev/disk/by-label/NIXOS";
    fsType = "btrfs";
    options = [
      "compress=zstd:6"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-label/SWAP";
    }
  ];

  boot.resumeDevice = "/dev/disk/by-label/SWAP";

  # Make sure mount point of user home exists
  environment.etc."tmpfiles.d/home-maik.conf".text = ''
    d /home/maik               700 1000 100 -
  '';

  # Mount subvolume that contains the user home
  systemd.mounts = [
    {
      type = "btrfs";
      mountConfig = {
        Options = "subvol=@maik";
      };
      what = "LABEL=NIXOS";
      where = "/home/maik";
    }
  ];

  # Enable rotation sensor
  hardware.sensor.iio.enable = true;

  # Make touch mode detection work reliable on StarLabs Starlite MKV
  nixpkgs.overlays = [
    (self: super: {
      mutter = super.mutter.overrideAttrs (oldAttrs: {
        patches =
          (oldAttrs.patches or [])
          ++ [
            (super.fetchpatch {
              url = "https://gitlab.gnome.org/GNOME/mutter/-/merge_requests/1846.patch";
              hash = "sha256-SgimR5iQwoJwH5T9CYpZJqiRm/1zy/qYpFzS0LwBY1g=";
            })
          ];
      });
    })
  ];

  powerManagement.enable = true;

  services.power-profiles-daemon.enable = true;
  # Suspend first then hibernate when closing the lid
  services.logind.settings.Login.HandleLidSwitch = "suspend-then-hibernate";
  # Hibernate on power button pressed
  services.logind.settings.Login.HandlePowerKey = "suspend-then-hibernate";

  # Define time delay for hibernation
  systemd.sleep.extraConfig = ''
    HibernateDelaySec=15m
    SuspendState=mem
  '';

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
