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
    # niri wm
    ../gui/niri.nix
    # Basic capabilities
    ../capabilities/chipcards.nix
    ../capabilities/mpv.nix
    ../capabilities/networking-with-network-manager.nix
    ../capabilities/pipewire.nix
    ../capabilities/printing.nix
    ../capabilities/ssh.nix
    ../capabilities/steam.nix
  ];

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Lanzaboote currently replaces the systemd-boot module.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
    autoEnrollKeys = {
      enable = true;
      autoReboot = true;
    };
    autoGenerateKeys.enable = true;
    measuredBoot = {
      enable = false;
      pcrs = [
        0
        4
        7
      ];
    };
  };

  # Network configuration
  networking.hostName = "styx";

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Enable firmware updates via fwupd
  services.fwupd.enable = true;

  # Autologin with greetd
  services.greetd = {
    enable = true;
    settings = rec {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd $SHELL";
      };
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "maik";
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
  ];

  # Not all software is free
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "google-chrome"
      "libvgm" # dependency of fooyin
      "steam"
      "steam-original"
      "steam-run"
      "steam-unwrapped"
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

  services.intel-lpmd = {
    enable = true;
    config.custom = {
      filename = "intel_lpmd_config_F6_M189.xml";
      content = ''
        <?xml version="1.0"?>

        <!--
        Specifies the configuration data
        for Intel Energy Optimizer (LPMD) daemon
        -->

        <Configuration>
        	<!--
        		CPU format example: 1,2,4..6,8-10
        	-->
        	<lp_mode_cpus></lp_mode_cpus>

        	<!--
        		EPP to use in Low Power Mode
        		0-255: Valid EPP value to use in Low Power Mode
        		   -1: Don't change EPP in Low Power Mode
        	-->
        	<lp_mode_epp></lp_mode_epp>

        	<!--
        		Mode values
        		0: Cgroup v2
        		1: Cgroup v2 isolate
        		2: CPU idle injection
        	-->
        	<Mode>1</Mode>

        	<!--
        		Default behavior when Performance power setting is used
        		-1: force off. (Never enter Low Power Mode)
        		 1: force on. (Always stay in Low Power Mode)
        		 0: auto. (opportunistic Low Power Mode enter/exit)
        	-->
        	<PerformanceDef>-1</PerformanceDef>

        	<!--
        		Default behavior when Balanced power setting is used
        		-1: force off. (Never enter Low Power Mode)
        		 1: force on. (Always stay in Low Power Mode)
        		 0: auto. (opportunistic Low Power Mode enter/exit)
        	-->
        	<BalancedDef>0</BalancedDef>

        	<!--
        		Default behavior when Power saver setting is used
        		-1: force off. (Never enter Low Power Mode)
        		 1: force on. (Always stay in Low Power Mode)
        		 0: auto. (opportunistic Low Power Mode enter/exit)
        	-->
        	<PowersaverDef>1</PowersaverDef>

        	<!--
        		Use HFI LPM hints
        		0 : No
        		1 : Yes
        	-->
        	<HfiLpmEnable>0</HfiLpmEnable>

        	<!--
        		Use WLT hints
        		0 : No
        		1 : Yes
        	-->
        	<WLTHintEnable>1</WLTHintEnable>

        	<!--
        		Use WLT hint Poll enable
        		0 : No
        		1 : Yes
        	-->
        	<WLTHintPollEnable>1</WLTHintPollEnable>

        	<!--
        		Use HFI SUV hints
        		0 : No
        		1 : Yes
        	-->
        	<HfiSuvEnable>0</HfiSuvEnable>

        	<!--
        		System utilization threshold to enter LP mode
        		from 0 - 100
        		clear both util_entry_threshold and util_exit_threshold to disable util monitor
        	-->
        	<util_entry_threshold>10</util_entry_threshold>

        	<!--
        		System utilization threshold to exit LP mode
        		from 0 - 100
        		clear both util_entry_threshold and util_exit_threshold to disable util monitor
        	-->
        	<util_exit_threshold>30</util_exit_threshold>

        	<!--
        		Entry delay. Minimum delay in non Low Power mode to
        		enter LPM mode.
        	-->
        	<EntryDelayMS>0</EntryDelayMS>

        	<!--
        		Exit delay. Minimum delay in Low Power mode to
        		exit LPM mode.
        	-->
        	<ExitDelayMS>0</ExitDelayMS>

        	<!--
        		Lowest hysteresis average in-LP-mode time in msec to enter LP mode
        		0: to disable hysteresis support
        	-->
        	<EntryHystMS>0</EntryHystMS>

        	<!--
        		Lowest hysteresis average out-of-LP-mode time in msec to exit LP mode
        		0: to disable hysteresis support
        	-->
        	<ExitHystMS>0</ExitHystMS>

        	<!--
        		Ignore ITMT setting during LP-mode enter/exit
        		0: disable ITMT upon LP-mode enter and re-enable ITMT upon LP-mode exit
        		1: do not touch ITMT setting during LP-mode enter/exit
        	-->
        	<IgnoreITMT>0</IgnoreITMT>

        	<!--
        		Example WorkLoad Type hints based config states applied to
        		12Pcore-8Ecore-2Lcore 28W TDP Meteor Lake platform.
        		Need to set WLTHintEnable to make it work.
        	-->
        	<States>
        		<CPUFamily> 6 </CPUFamily>
        		<CPUModel> 189 </CPUModel>
        		<CPUConfig> * </CPUConfig>
        		<State>
        			<ID> 1 </ID>
        			<Name> UTIL_IDLE </Name>
        			<WLTType> 1 </WLTType>
        			<ActiveCPUs> 4-7 </ActiveCPUs>
        			<EnterGFXLoadThres>50</EnterGFXLoadThres>
        			<IRQMigrate> -1 </IRQMigrate>
        			<EPP> 192 </EPP>
        			<EPB> 8 </EPB>
        			<ITMTState> -1 </ITMTState>
        			<MinPollInterval> 1000 </MinPollInterval>
        			<PollIntervalIncrement> 500 </PollIntervalIncrement>
        			<MaxPollInterval> 2000 </MaxPollInterval>
        		</State>
        		<State>
        			<ID> 2 </ID>
        			<Name> UTIL_IDLE_SUSTAIN </Name>
        			<ActiveCPUs> 0-7 </ActiveCPUs>
        			<EnterGFXLoadThres>75</EnterGFXLoadThres>
        			<WLTType> 2 </WLTType>
        			<IRQMigrate> -1 </IRQMigrate>
        			<EPP> 64 </EPP>
        			<EPB> 8 </EPB>
        			<ITMTState> -1 </ITMTState>
        			<MinPollInterval> 1000 </MinPollInterval>
        			<PollIntervalIncrement> 500 </PollIntervalIncrement>
        			<MaxPollInterval> 2000 </MaxPollInterval>
        		</State>
        		<State>
        			<ID> 3 </ID>
        			<Name> UTIL_IDLE_BURSTY </Name>
        			<WLTType> 3 </WLTType>
        			<ActiveCPUs> 4-7 </ActiveCPUs>
        			<EnterGFXLoadThres>75</EnterGFXLoadThres>
        			<IRQMigrate> -1 </IRQMigrate>
        			<EPP> 64 </EPP>
        			<EPB> 8 </EPB>
        			<ITMTState> -1 </ITMTState>
        			<MinPollInterval> 1000 </MinPollInterval>
        			<PollIntervalIncrement> 500 </PollIntervalIncrement>
        			<MaxPollInterval> 2000 </MaxPollInterval>
        		</State>
        		<State>
        			<ID> 4 </ID>
        			<Name> UTIL_IDLE_GFX_BUSY </Name>
        			<ActiveCPUs> 4-7 </ActiveCPUs>
        			<EnterGFXLoadThres>100</EnterGFXLoadThres>
        			<IRQMigrate> -1 </IRQMigrate>
        			<EPP> 128 </EPP>
        			<EPB> 8 </EPB>
        			<ITMTState> -1 </ITMTState>
        			<MinPollInterval> 1000 </MinPollInterval>
        			<PollIntervalIncrement> 500 </PollIntervalIncrement>
        			<MaxPollInterval> 2000 </MaxPollInterval>
        		</State>
        	</States>

        </Configuration>
      '';
    };
    mode = "AUTO";
    debug = true;
  };

  services.thermald.enable = true;

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # NixOS state version
  system.stateVersion = "24.05";
}
