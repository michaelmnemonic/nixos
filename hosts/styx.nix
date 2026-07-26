{pkgs, ...}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/styx.nix
    # Users
    ../users/maik.nix
    # plasma desktop environment
    ../gui/plasma.nix
    # Basic capabilities
    ../capabilities/chipcards.nix
    ../capabilities/networking-with-network-manager.nix
    ../capabilities/pipewire.nix
    ../capabilities/plasma-pim.nix
    ../capabilities/printing.nix
    ../capabilities/ssh.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Network configuration
  networking.hostName = "styx";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable firmware updates via fwupd
  services.fwupd.enable = true;

  # Manage displays with SDDM
  services.displayManager = {
    autoLogin = {
      enable = true;
      user = "maik";
    };
    sddm = {
      enable = true;
      wayland = {
        enable = true;
        compositor = "kwin";
      };
    };
  };

  # Fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    firefox
    kdePackages.tokodon
    kdePackages.neochat
  ];

  # Customize kde plasma
  nixpkgs.overlays = [
    (final: prev: {
      kdePackages = prev.kdePackages.overrideScope (sfinal: sprev: {
        # smaller systemtray icons with more spacing
        # FIXME: this compiles plasma-workspace just to patch qml script
        plasma-workspace = sprev.plasma-workspace.overrideAttrs (oldAttrs: {
          patches =
            oldAttrs.patches
            ++ [
              ../patches/0001-plasma-workspaces-systemtray-icon-sizes.patch
            ];
        });
      });
    })
  ];

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

  ############
  # Services #
  ############

  services.tuned = {
    enable = true;
    profiles = {
      styx-balanced-battery = {
        cpu = {
          governor = "performance";
          energy_perf_bias = "default";
          energy_performance_preference = "default";
          pm_qos_resume_latency_us = "0";
          boost = "1";
        };
        audio = {
          timeout = 5;
        };
        usb = {
          autosuspend = 5;
        };
        net = {
          devices = "wlp0s20f3";
          wake_on_lan = "d";
        };
        modules = {
          iwlwifi = "+r power_save=1 power_level=1";
        };
        sysfs = {
          # Increase writeback time
          "/proc/sys/vm/dirty_writeback_centisecs" = 1500;
          # Disable nmi watchdog
          "/proc/sys/kernel/nmi_watchdog" = 0;
          # Power save for audio
          "/sys/module/snd_hda_intel/parameters/power_save" = 1;
          # Power policy for PCI devices
          "/sys/module/pcie_aspm/parameters/policy" = "powersupersave";
          "/sys/bus/pci/devices/0000:00:0a.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:04.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:1f.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:55:00.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:13.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:14.3/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:1f.5/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:00.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:14.2/power/control" = "auto";
          "/sys/bus/pci/devices/0000:56:00.0/power/control" = "auto";
          "/sys/bus/pci/devices/0000:00:1f.4/power/control" = "auto";
        };
      };
    };
    ppdSettings.battery = {
      balanced = "styx-balanced-battery";
    };
  };

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # NixOS state version
  system.stateVersion = "24.05";
}
