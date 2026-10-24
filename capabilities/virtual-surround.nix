{
  pkgs,
  ...
}:
let
  # SOFA HRIR data file for the 7.1.4 surround spatializer
  hrir-sofa = pkgs.runCommand "hrir-sofa" {} ''
    install -D -m 444 ${../ressources/hrir.sofa} $out/hrir.sofa
  '';
  in
{
  services.pipewire.configPackages = [
  # Surround sound for headphones using HRTF inspired by https://github.com/DekoDX/Pipewire-DX-Utils/
  (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/11-surround-7-1-4.conf" ''
    context.modules = [
    { name = libpipewire-module-filter-chain
            flags = [ nofail ]
            args = {
                node.description = "7.1.4 Surround Sound"
                media.name       = "7.1.4 Surround Sound"
                filter.graph = {
                    nodes = [
                        {
                            type = sofa
                            label = spatializer
                            name = spFL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 30.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spFR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 330.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spFC
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 0.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spRL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 150.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spRR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 210.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spSL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 90.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spSR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 270.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spLFE
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 180.0
                                "Elevation"  = 0.0
                                "Radius"     = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spTFL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"   = 30.0
                                "Elevation" = 75.0
                                "Radius"    = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spTFR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"   = 330.0
                                "Elevation" = 75.0
                                "Radius"    = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spTRL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"   = 150.0
                                "Elevation" = 75.0
                                "Radius"    = 75.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            name = spTRR
                            control= {
                                "Azimuth"   = 210.0
                                "Elevation" = 75.0
                                "Radius"    = 75.0
                            }
                        }
                        { type = builtin label = mixer name = mixTL }
                        { type = builtin label = mixer name = mixTR }
                        { type = builtin label = mixer name = mixBL }
                        { type = builtin label = mixer name = mixBR }
                        { type = builtin label = mixer name = mixL }
                        { type = builtin label = mixer name = mixR }
                    ]
                    links = [
                        { output = "spFL:Out L"  input="mixBL:In 1"  }
                        { output = "spFL:Out R"  input="mixBR:In 1"  }
                        { output = "spFR:Out L"  input="mixBL:In 2"  }
                        { output = "spFR:Out R"  input="mixBR:In 2"  }
                        { output = "spFC:Out L"  input="mixBL:In 3"  }
                        { output = "spFC:Out R"  input="mixBR:In 3"  }
                        { output = "spRL:Out L"  input="mixBL:In 4"  }
                        { output = "spRL:Out R"  input="mixBR:In 4"  }
                        { output = "spRR:Out L"  input="mixBL:In 5"  }
                        { output = "spRR:Out R"  input="mixBR:In 5"  }
                        { output = "spSL:Out L"  input="mixBL:In 6"  }
                        { output = "spSL:Out R"  input="mixBR:In 6"  }
                        { output = "spSR:Out L"  input="mixBL:In 7"  }
                        { output = "spSR:Out R"  input="mixBR:In 7"  }
                        { output = "spLFE:Out L" input="mixBL:In 8"  }
                        { output = "spLFE:Out R" input="mixBR:In 8"  }
                        { output = "spTFL:Out L" input = "mixTL:In 1" }
                        { output = "spTFL:Out R" input = "mixTR:In 1" }
                        { output = "spTFR:Out L" input = "mixTL:In 2" }
                        { output = "spTFR:Out R" input = "mixTR:In 2" }
                        { output = "spTRL:Out L" input = "mixTL:In 3" }
                        { output = "spTRL:Out R" input = "mixTR:In 3" }
                        { output = "spTRR:Out L" input = "mixTL:In 4" }
                        { output = "spTRR:Out R" input = "mixTR:In 4" }
                        { output = "mixBL:Out" input = "mixL:In 1" }
                        { output = "mixTL:Out" input = "mixL:In 2" }
                        { output = "mixBR:Out" input = "mixR:In 1" }
                        { output = "mixTR:Out" input = "mixR:In 2" }

                    ]
                    inputs  = [ "spFL:In" "spFR:In" "spFC:In" "spLFE:In" "spRL:In" "spRR:In" "spSL:In" "spSR:In" "spTFL:In" "spTFR:In" "spTRL:In" "spTRR:In"  ]
                    outputs = [ "mixL:Out" "mixR:Out" ]
                }
                sink.props = {
                    node.target = "output.effect_convolver"
                }
                capture.props = {
                    node.name      = "effect_input.spatializer"
                    media.class    = Audio/Sink
                    audio.rate = 48000
                    audio.channels = 12
                    audio.position = [ FL FR FC LFE RL RR SL SR TFL TFR TRL TRR ]
                }
                playback.props = {
                    node.name      = "effect_output.spatializer"
                    node.passive   = true
                    audio.rate = 48000
                    audio.channels = 2
                    audio.position = [ FL FR ]
                }
            }
        }
    ]
  '')
  (pkgs.writeTextDir "share/pipewire/pipewire.conf.d/12-surround-7-1.conf" ''
    context.modules = [
    { name = libpipewire-module-filter-chain
            flags = [ nofail ]
            args = {
                node.description = "7.1 Surround Sound"
                media.name       = "7.1 Surround Sound"
                filter.graph = {
                    nodes = [
                        {
                            type = sofa
                            label = spatializer
                            name = spFL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 30.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spFR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 330.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spFC
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 0.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spRL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 150.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spRR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 210.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spSL
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 90.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spSR
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 270.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }
                        {
                            type = sofa
                            label = spatializer
                            name = spLFE
                            config = {
                                filename = "${hrir-sofa}/hrir.sofa"
                            }
                            control = {
                                "Azimuth"    = 180.0
                                "Elevation"  = 0.0
                                "Radius"     = 3.0
                            }
                        }

                        { type = builtin label = mixer name = mixL }
                        { type = builtin label = mixer name = mixR }
                    ]
                    links = [
                        { output = "spFL:Out L"  input="mixL:In 1" }
                        { output = "spFL:Out R"  input="mixR:In 1" }
                        { output = "spFR:Out L"  input="mixL:In 2" }
                        { output = "spFR:Out R"  input="mixR:In 2" }
                        { output = "spFC:Out L"  input="mixL:In 3" }
                        { output = "spFC:Out R"  input="mixR:In 3" }
                        { output = "spRL:Out L"  input="mixL:In 4" }
                        { output = "spRL:Out R"  input="mixR:In 4" }
                        { output = "spRR:Out L"  input="mixL:In 5" }
                        { output = "spRR:Out R"  input="mixR:In 5" }
                        { output = "spSL:Out L"  input="mixL:In 6" }
                        { output = "spSL:Out R"  input="mixR:In 6" }
                        { output = "spSR:Out L"  input="mixL:In 7" }
                        { output = "spSR:Out R"  input="mixR:In 7" }
                        { output = "spLFE:Out L" input="mixL:In 8" }
                        { output = "spLFE:Out R" input="mixR:In 8" }
                    ]
                    inputs  = [ "spFL:In" "spFR:In" "spFC:In" "spLFE:In" "spRL:In" "spRR:In", "spSL:In", "spSR:In" ]
                    outputs = [ "mixL:Out" "mixR:Out" ]
                }
                sink.props = {
                    node.target = "output.effect_convolver"
                }
                capture.props = {
                    node.name      = "input.effect_71"
                    media.class    = Audio/Sink
                    audio.channels = 8
                    audio.position = [ FL FR FC LFE RL RR SL SR ]
                }
                playback.props = {
                    node.name      = "output.effect_71"
                    node.passive   = true
                    audio.channels = 2
                    audio.position = [ FL FR ]
                }
            }
        }
    ]
  '')
  ];
}
