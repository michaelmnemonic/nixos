{pkgs, ...}: {
  # Disable pulseaudio
  service.pulseaudio.enable = false;

  # Enable rtkit for (some) realtime support
  security.rtkit.enable = true;

  # Enable pipewire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;

    # Configure pipewise
    configPackages = [
      # Prevent resampling of sample rate the DAC natively supports
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/00-prevent-resampling.conf" ''
        context.properties = {
          link.max-buffers = 16           # version < 3 clients can't handle more

          core.daemon = true              # listening for socket connections
          core.name   = pipewire-0        # core name and socket name

          ## Properties for the DSP configuration.
          default.clock.rate          = 48000
          default.clock.allowed-rates = [ 44100 48000 88200 96000 ]
          default.clock.quantum       = 512
          default.clock.min-quantum   = 32
          default.clock.max-quantum   = 1024
          #default.clock.quantum-limit = 8192
          #default.video.width         = 640
          #default.video.height        = 480
          #default.video.rate.num      = 25
          #default.video.rate.denom    = 1

          # These overrides are only applied when running in a vm.
          vm.overrides = {
              default.clock.min-quantum = 1024
          }

          # keys checked below to disable module loading
          module.x11.bell = true
          # enables autoloading of access module, when disabled an alternative
          # access module needs to be loaded.
          module.access = true
        }
      '')
    ];

    # Configure wireplumber (pipewire session manager)
    wireplumber = {
      enable = true;
      configPackages = [
        # Prettier name for usb-c headset
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-usb-c-headphones.conf" ''
          monitor.alsa.rules = [
             {
              matches = [
                {
                  node.name = "alsa_output.usb-KTMicro_KT_USB_Audio_2020-02-20-0000-0000-0000--00.analog-stereo"
                }
              ]
              actions = {
                update-props = {
                  node.nick              = "Kopfhörer"
                  node.description       = "Kopfhörer"
                }
              }
            }
          ]
        '')

        # Prettier name for speakers of charon
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-lenovo-x13s-speakers.conf" ''
          monitor.alsa.rules = [
             {
              matches = [
                {
                  node.name = "alsa_output.platform-sound.HiFi__Speaker__sink"
                }
              ]
              actions = {
                update-props = {
                  node.nick                  = "Lautsprecher"
                  node.description           = "Lautsprecher"
                  device.profile.description = "Lautsprecher"
                }
              }
            }
          ]
        '')

        # Prettier name for USB DAC
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-usb-dac.conf" ''
          monitor.alsa.rules = [
             {
              matches = [
                {
                  node.name = "alsa_output.usb-SMSL_SMSL_USB_AUDIO-00.analog-stereo"
                }
              ]
              actions = {
                update-props = {
                  node.nick              = "USB DAC"
                  node.description       = "USB DAC"
                }
              }
            }
          ]
        '')

        # Prettier name for desktop monitor
        (pkgs.writeTextDir "share/wireplumber/wireplumber.conf.d/10-lg-monitor.conf" ''
          monitor.alsa.rules = [
             {
              matches = [
                {
                  node.name = "alsa_output.pci-0000_08_00.1.hdmi-stereo"
                }
              ]
              actions = {
                update-props = {
                  node.nick              = "Monitor"
                  node.description       = "Monitor"
                }
              }
            }
          ]
        '')
      ];
    };
  };
}
