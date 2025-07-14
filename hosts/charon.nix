{
  inputs,
  pkgs,
  nixos-x13s,
  lib,
  self,
  allowed-unfree-packages,
  ...
}: {
  imports = [
    # Shared host configuration
    ./_shared.nix
    # Hardware configuration
    ../hardware/charon.nix
    # Users
    ../users/maik.nix
    # PLASMA desktop
    ../gui/plasma.nix
    # SSH
    ../capabilities/ssh.nix
    # vscode
    ../capabilities/vscode.nix
    # Basic capabilites
    ../capabilities/pipewire.nix
    ../capabilities/printing.nix
    ../capabilities/scanning.nix
    ../capabilities/chipcards.nix
  ];

  # Enable X13S support
  # FIXME: logically this is hardware-specifc, but flakes only import one level deep, so placing it in hardware/ is not not possible 🤔
  nixos-x13s = {
    enable = true;
    wifiMac = "F4:A8:0D:F5:5D:BC";
    bluetoothMac = "F4:A8:0D:30:9D:8B";
    kernel = "jhovold";
  };

  # Allow unfree software
  nixpkgs.config.allowUnfree = true;

  # Network configuration
  networking.hostName = "charon";
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;
  networking.modemmanager.fccUnlockScripts = [
    {
      id = "105b:e0c3";
      path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
    }
  ];

  # energy managment
  services.power-profiles-daemon.enable = true;
  # Suspend first then hibernate when closing the lid
  services.logind.lidSwitch = "hibernate";
  # Hibernate on power button pressed
  services.logind.powerKey = "hibernate";
  services.logind.powerKeyLongPress = "poweroff";

  # Enable SDDM
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };
  };

  # Enable kodi session
  services.xserver.desktopManager.kodi.enable = true;

  # Firewall configuration
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [
      # syncthing
      22000 # sync
      # transmission
      43219
    ];
    allowedTCPPortRanges = [
      # kdeconnect
      {
        from = 1714;
        to = 1764;
      }
    ];
    allowedUDPPorts = [
      # syncthing
      22000
      21027
      # transmission
      43219
      # wireguard
      51871
    ];
    allowedUDPPortRanges = [
      # kdeconnect
      {
        from = 1714;
        to = 1764;
      }
    ];
    # if packets are still dropped, they will show up in dmesg
    logReversePathDrops = true;
    # wireguard trips rpfilter up
    extraCommands = ''
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --sport 1637 -j RETURN
      ip46tables -t mangle -I nixos-fw-rpfilter -p udp -m udp --dport 1637 -j RETURN
    '';
    extraStopCommands = ''
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --sport 1637 -j RETURN || true
      ip46tables -t mangle -D nixos-fw-rpfilter -p udp -m udp --dport 1637 -j RETURN || true
    '';
  };

  # Enable bluetooth
  hardware.bluetooth.enable = true;

  # Fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    anytype
    (pkgs.kodi.withPackages (kodiPkgs:
      with pkgs; [
        python312Packages.pillow
      ]))
    zed-editor
  ];

  # Make sure syncthing home exists
  environment.etc."tmpfiles.d/var-lib-synthing.conf".text = ''
    d /var/lib/syncthing       700 1000 100 -
  '';

  services.pipewire.configPackages = [
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
  ];

  ############
  # Programs #
  ############

  # Enable direnv
  programs.direnv.enable = true;

  # Make fish shell availlable
  programs.fish.enable = true;

  ############
  # Services #
  ############

  # Enable mDNS
  services.avahi.enable = true;

  # syncthing
  services.syncthing = {
    enable = true;
    user = "maik";
  };

  # tailscale
  services.tailscale.enable = true;

  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
    };
  };

  # Use only three cores for compilation -- this device is passivly cooled
  nix = {
    settings = {
      cores = 3;
      max-jobs = 1;
    };
  };

  # NixOS state version
  system.stateVersion = "24.05";
}
