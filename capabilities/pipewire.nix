{pkgs, ...}: {
  # Disable pulseaudio
  hardware.pulseaudio.enable = false;

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

      # Provide equalizer for Desktop Speakers
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-kef-speakers.conf" ''
          context.modules = [
            { name = libpipewire-module-filter-chain
              args = {
                node.description = "Desktoplautsprecher"
                media.name       = "Desktoplautsprecher"
                filter.graph = {
                    nodes = [
                        {
                            type  = builtin
                            name  = eq_band_1
                            label = bq_peaking
                            control = { "Freq" = 139 "Q" = 3.17 "Gain" = -6.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_2
                            label = bq_peaking
                            control = { "Freq" = 184 "Q" = 2.0 "Gain" = -8.8 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_3
                            label = bq_peaking
                            control = { "Freq" = 265 "Q" = 1.79 "Gain" = -7.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_4
                            label = bq_peaking
                            control = { "Freq" = 320 "Q" = 1.92 "Gain" = 3.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_5
                            label = bq_peaking
                            control = { "Freq" = 327 "Q" = 6.27 "Gain" = -4.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_6
                            label = bq_peaking
                            control = { "Freq" = 1720 "Q" = 7.09 "Gain" = 1.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_7
                            label = bq_peaking
                            control = { "Freq" = 1813 "Q" = 3.06 "Gain" = -2.2 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_8
                            label = bq_peaking
                            control = { "Freq" = 2569 "Q" = 1.87 "Gain" = 2.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_9
                            label = bq_peaking
                            control = { "Freq" = 2932 "Q" = 2.27 "Gain" = -3.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_10
                            label = bq_peaking
                            control = { "Freq" = 4707 "Q" = 4.35 "Gain" = -2.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_11
                            label = bq_peaking
                            control = { "Freq" = 5141 "Q" = 1.45 "Gain" = 3.9 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_12
                            label = bq_peaking
                            control = { "Freq" = 6862 "Q" = 1.82 "Gain" = -4.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_13
                            label = bq_peaking
                            control = { "Freq" = 11002 "Q" = 1.0 "Gain" = -3.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_14
                            label = bq_peaking
                            control = { "Freq" = 15390 "Q" = 1.53 "Gain" = -3.7 }
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
                        { output = "eq_band_11:Out" input = "eq_band_12:In" }
                        { output = "eq_band_12:Out" input = "eq_band_13:In" }
                        { output = "eq_band_13:Out" input = "eq_band_14:In" }
                    ]
                }
            audio.channels = 2
            audio.position = [ FL FR ]
                capture.props = {
                    node.name   = "effect_input.eq14"
                    media.class = Audio/Sink
                }
                playback.props = {
                    node.name   = "effect_output.eq14"
                    node.target = "alsa_output.usb-SMSL_SMSL_USB_AUDIO-00.analog-stereo"
                    node.passive = true
                }
            }
          }
        ]
      '')

      # Provide equalizer for Lenovo X13s speakers
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-x13s-speakers.conf" ''
          context.modules = [
            { name = libpipewire-module-filter-chain
              args = {
                node.description = "Notebooklautsprecher"
                media.name       = "Notebooklautsprecher"
                filter.graph = {
                    nodes = [
                        {
                            type  = builtin
                            name  = eq_band_1
                            label = bq_peaking
                            control = { "Freq" = 673 "Q" = 1.78 "Gain" = -7.9 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_2
                            label = bq_peaking
                            control = { "Freq" = 1065 "Q" = 1.74 "Gain" = -5.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_3
                            label = bq_peaking
                            control = { "Freq" = 1199 "Q" = 5.0 "Gain" = -1.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_4
                            label = bq_peaking
                            control = { "Freq" = 1490 "Q" = 3.65 "Gain" = 3.2 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_5
                            label = bq_peaking
                            control = { "Freq" = 1946 "Q" = 1.88 "Gain" = -10.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_6
                            label = bq_peaking
                            control = { "Freq" = 2176 "Q" = 5.0 "Gain" = -1.6 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_7
                            label = bq_peaking
                            control = { "Freq" = 2822 "Q" = 2.82 "Gain" = 3.5 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_8
                            label = bq_peaking
                            control = { "Freq" = 3033 "Q" = 1.0 "Gain" = -5.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_9
                            label = bq_peaking
                            control = { "Freq" = 3991 "Q" = 5.0 "Gain" = -0.9 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_10
                            label = bq_peaking
                            control = { "Freq" = 5101 "Q" = 7.50 "Gain" = 1.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_11
                            label = bq_peaking
                            control = { "Freq" = 8831 "Q" = 1.00 "Gain" = -11.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_12
                            label = bq_peaking
                            control = { "Freq" = 11959 "Q" = 5.0 "Gain" = -1.6 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_13
                            label = bq_peaking
                            control = { "Freq" = 14120 "Q" = 1.50 "Gain" = -10.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_14
                            label = bq_peaking
                            control = { "Freq" = 15509 "Q" = 1.86 "Gain" = 4.9 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_15
                            label = bq_peaking
                            control = { "Freq" = 17984 "Q" = 1.0 "Gain" = -7.0 }
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
                        { output = "eq_band_11:Out" input = "eq_band_12:In" }
                        { output = "eq_band_12:Out" input = "eq_band_13:In" }
                        { output = "eq_band_13:Out" input = "eq_band_14:In" }
                        { output = "eq_band_14:Out" input = "eq_band_15:In" }
                    ]
                }
            audio.channels = 2
            audio.position = [ FL FR ]
                capture.props = {
                    node.name   = "effect_input.eq15"
                    media.class = Audio/Sink
                }
                playback.props = {
                    node.name   = "effect_output.eq15"
                    node.target = "alsa_output.platform-sound.HiFi__Speaker__sink"
                    node.passive = true
                }
            }
          }
        ]
      '')

      # Provide equalizer for StarLabs Star Lite Mk V speaker
      (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/10-starlabs-star-lite-mk-v.conf" ''
          context.modules = [
            { name = libpipewire-module-filter-chain
              args = {
                node.description = "Lautsprecher"
                media.name       = "Lautsprecher"
                filter.graph = {
                    nodes = [
                        {
                            type  = builtin
                            name  = eq_band_1
                            label = bq_peaking
                            control = { "Freq" = 479 "Q" = 1.0 "Gain" = 6.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_2
                            label = bq_peaking
                            control = { "Freq" = 531 "Q" = 1.0 "Gain" = 7.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_3
                            label = bq_peaking
                            control = { "Freq" = 566 "Q" = 5.72 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_4
                            label = bq_peaking
                            control = { "Freq" = 583 "Q" = 1.73 "Gain" = -31.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_5
                            label = bq_peaking
                            control = { "Freq" = 696 "Q" = 1.24 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_6
                            label = bq_peaking
                            control = { "Freq" = 800 "Q" = 5.0 "Gain" = -2.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_7
                            label = bq_peaking
                            control = { "Freq" = 882 "Q" = 3.21 "Gain" = -12.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_8
                            label = bq_peaking
                            control = { "Freq" = 1164 "Q" = 3.66 "Gain" = -6.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_9
                            label = bq_peaking
                            control = { "Freq" = 1317 "Q" = 7.48 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_10
                            label = bq_peaking
                            control = { "Freq" = 1397 "Q" = 4.96 "Gain" = -6.6 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_11
                            label = bq_peaking
                            control = { "Freq" = 1645 "Q" = 4.59 "Gain" = -7.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_12
                            label = bq_peaking
                            control = { "Freq" = 1670 "Q" = 7.35 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_13
                            label = bq_peaking
                            control = { "Freq" = 2258 "Q" = 4.34 "Gain" = 1.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_14
                            label = bq_peaking
                            control = { "Freq" = 2403 "Q" = 1.0 "Gain" = 7.5 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_15
                            label = bq_peaking
                            control = { "Freq" = 2403 "Q" = 2.56 "Gain" = -11.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_16
                            label = bq_peaking
                            control = { "Freq" = 3157 "Q" = 1.87 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_17
                            label = bq_peaking
                            control = { "Freq" = 3266 "Q" = 4.64 "Gain" = -8.7 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_18
                            label = bq_peaking
                            control = { "Freq" = 4060 "Q" = 1.86 "Gain" = -10.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_19
                            label = bq_peaking
                            control = { "Freq" = 4658 "Q" = 2.72 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_20
                            label = bq_peaking
                            control = { "Freq" = 5174 "Q" = 4.82 "Gain" = -9.1 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_21
                            label = bq_peaking
                            control = { "Freq" = 6704 "Q" = 2.62 "Gain" = 5.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_22
                            label = bq_peaking
                            control = { "Freq" = 6765 "Q" = 1.99 "Gain" = 9.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_23
                            label = bq_peaking
                            control = { "Freq" = 6873 "Q" = 1.15 "Gain" = -25.0 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_24
                            label = bq_peaking
                            control = { "Freq" = 7234 "Q" = 2.88 "Gain" = -8.9 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_25
                            label = bq_peaking
                            control = { "Freq" = 14362 "Q" = 3.77"Gain" = -7.4 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_26
                            label = bq_peaking
                            control = { "Freq" = 15258 "Q" = 1.0 "Gain" = 2.3 }
                        }
                        {
                            type  = builtin
                            name  = eq_band_27
                            label = bq_peaking
                            control = { "Freq" = 16182 "Q" = 1.62 "Gain" = 2.2 }
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
                        { output = "eq_band_11:Out" input = "eq_band_12:In" }
                        { output = "eq_band_12:Out" input = "eq_band_13:In" }
                        { output = "eq_band_13:Out" input = "eq_band_14:In" }
                        { output = "eq_band_14:Out" input = "eq_band_15:In" }
                        { output = "eq_band_15:Out" input = "eq_band_16:In" }
                        { output = "eq_band_16:Out" input = "eq_band_17:In" }
                        { output = "eq_band_17:Out" input = "eq_band_18:In" }
                        { output = "eq_band_18:Out" input = "eq_band_19:In" }
                        { output = "eq_band_19:Out" input = "eq_band_20:In" }
                        { output = "eq_band_20:Out" input = "eq_band_21:In" }
                        { output = "eq_band_21:Out" input = "eq_band_22:In" }
                        { output = "eq_band_22:Out" input = "eq_band_23:In" }
                        { output = "eq_band_23:Out" input = "eq_band_24:In" }
                        { output = "eq_band_24:Out" input = "eq_band_25:In" }
                        { output = "eq_band_25:Out" input = "eq_band_26:In" }
                        { output = "eq_band_26:Out" input = "eq_band_27:In" }
                    ]
                }
            audio.channels = 2
            audio.position = [ FL FR ]
                capture.props = {
                    node.name   = "effect_input.eq27"
                    media.class = Audio/Sink
                }
                playback.props = {
                    node.name   = "effect_output.eq27"
                    node.target = "alsa_output.pci-0000_00_1f.3.analog-stereo"
                    node.passive = true
                }
            }
          }
        ]
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
