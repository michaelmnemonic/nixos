{pkgs, ...}: {
  # Use pipewire
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    configPackages = [
      # Prevent resampling of sample rate the DAC nativly supports
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
      # Provide equalizer for Moondrop Para
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-moondrop-para.conf" ''
          context.modules = [
            { name = libpipewire-module-filter-chain
                args = {
                    node.description = "Moondrop Para"
                    media.name       = "Moondrop Para"
                    filter.graph = {
                        nodes = [
                            {
                                type  = builtin
                                name  = eq_band_1
                                label = bq_highshelf
                                control = { "Freq" = 0 "Q" = 1.0 "Gain" = -6.2 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_2
                                label = bq_lowshelf
                                control = { "Freq" = 105.0 "Q" = 0.7 "Gain" = 6.5 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_3
                                label = bq_peaking
                                control = { "Freq" = 44 "Q" = 2.22 "Gain" = 0.9 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_4
                                label = bq_peaking
                                control = { "Freq" = 110 "Q" = 0.34 "Gain" = -1.9 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_5
                                label = bq_peaking
                                control = { "Freq" = 1998 "Q" = 1.55 "Gain" = 3.2 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_6
                                label = bq_peaking
                                control = { "Freq" = 3121 "Q" = 3.17 "Gain" = -4.0 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_7
                                label = bq_peaking
                                control = { "Freq" = 152 "Q" = 2.15 "Gain" = 0.6 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_8
                                label = bq_peaking
                                control = { "Freq" = 227 "Q" = 1.43 "Gain" = -0.5 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_9
                                label = bq_peaking
                                control = { "Freq" = 6612 "Q" = 5.96 "Gain" = 3.1 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_10
                                label = bq_peaking
                                control = { "Freq" = 9319 "Q" = 3.75 "Gain" = -2.9 }
                            }
                            {
                                type  = builtin
                                name  = eq_band_11
                                label = bq_highshelf
                                control = { "Freq" = 10000.0 "Q" = 0.7 "Gain" = -4.1 }
                            }
                        ]
                        links = [
                            { output = "eq_band_1:Out" input = "eq_band_2:In" }
                            { output = "eq_band_2:Out" input = "eq_band_3:In" }
                            { output = "eq_band_3:Out" input = "eq_band_4:In" }
                            { output = "eq_band_4:Out" input = "eq_band_5:In" }
                            { output = "eq_band_5:Out" input = "eq_band_6:In" }
                            { output = "eq_band_6:Out" input = "eq_band_7:In" }
                            { output = "eq_band_7:Out" input = "eq_band_8:In" }
                            { output = "eq_band_8:Out" input = "eq_band_9:In" }
                            { output = "eq_band_9:Out" input = "eq_band_10:In" }
                            { output = "eq_band_10:Out" input = "eq_band_11:In" }
                        ]
                    }
                audio.channels = 2
                audio.position = [ FL FR ]
                    capture.props = {
                        node.name   = "effect_input.eq11"
                        media.class = Audio/Sink
                    }
                    playback.props = {
                        node.name   = "effect_output.eq11"
                        node.target = "alsa_output.usb-SMSL_SMSL_USB_AUDIO-00.analog-stereo"
                        node.passive = true
                    }
                }
            }
        ]
      '')
    ];
    wireplumber = {
      enable = true;
      configPackages = [
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
                  node.nick              = "Lautsprecher"
                  node.description       = "Lautsprecher"
                }
              }
            }
          ]
        '')
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
                  node.description       = "LG UltraWide 38WN95CP-W"
                }
              }
            }
          ]
        '')
      ];
    };
  };
}
