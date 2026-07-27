{
  pkgs,
  lib,
  ...
}: {
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
    ../capabilities/mpv.nix
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
    (pkgs.kodi-wayland.withPackages (
      kodiPkgs:
        with pkgs; [
          python312Packages.pillow
        ]
    ))
    firefox
    fooyin
    kdePackages.tokodon
    kdePackages.neochat
  ];

  # Not all software is free
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "libvgm" # dependency of fooyin
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
      styx-performance = {
        cpu = {
          governor = "performance";
          energy_perf_bias = "performance";
          energy_performance_preference = "performance";
          pm_qos_resume_latency_us = "0";
          boost = "1";
        };
        audio = {
          timeout = 30;
        };
        usb = {
          autosuspend = 0;
        };
        net = {
          devices = "wlp0s20f3";
          wake_on_lan = "d";
        };
        sysfs = {
          # Increase writeback time
          "/proc/sys/vm/dirty_writeback_centisecs" = 1500;
          # Disable nmi watchdog
          "/proc/sys/kernel/nmi_watchdog" = 0;
          # Power save for audio
          "/sys/module/snd_hda_intel/parameters/power_save" = 0;
          # Power policy for PCI devices
          "/sys/module/pcie_aspm/parameters/policy" = "performance";
          "/sys/bus/pci/devices/0000:00:0a.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:04.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:1f.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:55:00.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:13.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:14.3/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:1f.5/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:00.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:14.2/power/control" = "on";
          "/sys/bus/pci/devices/0000:56:00.0/power/control" = "on";
          "/sys/bus/pci/devices/0000:00:1f.4/power/control" = "on";
          # iGPU
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt0/freq0/power_profile" = "base";
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt1/freq0/power_profile" = "base";
        };
      };
      styx-performance-battery = {
        cpu = {
          governor = "performance";
          energy_perf_bias = "performance";
          energy_performance_preference = "performance";
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
        sysfs = {
          # Increase writeback time
          "/proc/sys/vm/dirty_writeback_centisecs" = 1500;
          # Disable nmi watchdog
          "/proc/sys/kernel/nmi_watchdog" = 0;
          # Power save for audio
          "/sys/module/snd_hda_intel/parameters/power_save" = 1;
          # Power policy for PCI devices
          "/sys/module/pcie_aspm/parameters/policy" = "powersave";
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
          # iGPU
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt0/freq0/power_profile" = "base";
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt1/freq0/power_profile" = "base";
        };
      };
      styx-balanced-battery = {
        cpu = {
          governor = "performance";
          energy_perf_bias = "balance-performance";
          energy_performance_preference = "balance_performance";
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
          # iGPU
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt0/freq0/power_profile" = "power_saving";
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt1/freq0/power_profile" = "power_saving";
        };
      };
      styx-powersave-battery = {
        cpu = {
          governor = "performance";
          energy_perf_bias = "power";
          energy_performance_preference = "power";
          pm_qos_resume_latency_us = "0";
          boost = "0";
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
          # iGPU
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt0/freq0/power_profile" = "power_saving";
          "/sys/devices/pci0000:00/0000:00:02.0/tile0/gt1/freq0/power_profile" = "power_saving";
        };
      };
    };
    ppdSettings = {
      profiles = {
        balanced = "styx-balanced-battery";
        performance = "styx-performance";
        power-saver = "styx-powersave-battery";
      };
      battery = {
        balanced = "styx-balanced-battery";
        power-saver = "styx-powersave-battery";
        performance = "styx-performance-battery";
      };
    };
  };

  # Restrict system-level daemons to efficency cores after start-up
  systemd.slices."system".sliceConfig = {
    AllowedCPUs = "4-7";
    StartupAllowedCPUs = "";
  };

  # Restrict user session components to efficency cores after start-up
  systemd.user.slices."session".sliceConfig = {
    AllowedCPUs = "4-7";
    StartupAllowedCPUs = "";
  };

  # Restrict user background tasks to efficency cores after start-up
  systemd.user.slices."background".sliceConfig = {
    AllowedCPUs = "4-7";
    StartupAllowedCPUs = "";
  };

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # NixOS state version
  system.stateVersion = "24.05";
}
