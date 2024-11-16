{pkgs, ...}: {
  imports = [
    ./hardware/pluto.nix
    ./_shared/common.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "pluto";

  # Disable mitigations for performance
  # FIXME: is this a good idea?
  boot.kernelParams = [
    "mitigations=off"
  ];

  # Allow overclocking the AMD GPU
  boot.kernelParams = ["amdgpu.ppfeaturemask=0xfff7ffff" "amd_pstate=active"];

  # Overclock and undervolt AMD GPU

  environment.etc."tmpfiles.d/gpu-undervolt.conf".text = ''
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - vo -100\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - m 1 1200\n
    w+ /sys/class/drm/card1/device/pp_od_clk_voltage                - - - - c\n
    w /sys/class/drm/card1/device/pp_power_profile_mode             - - - - 1
  '';

  # Use latest stable kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Boot splash screen
  boot.plymouth.enable = true;

  # Use german keyboard layout
  services.xserver = {
    # set keymap
    xkb.layout = "de";
  };

  # Use plasma as desktop environment
  services.desktopManager.plasma6.enable = true;

  # Use SDDM as displayManager
  services.displayManager.sddm = {
    enable = true;
    wayland = {
      enable = true;
      compositor = "kwin";
    };
  };

  # Use NetworkManager
  networking.networkmanager.enable = true;

  # Disable NetworkManager wait online
  systemd.services."NetworkManager-wait-online".enable = false;

  # Add inter, jetbrains-mono and noto fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk
    noto-fonts-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    (catppuccin-kde.override {
      flavour = ["mocha" "latte"];
      accents = ["rosewater"];
    })
    aspell
    aspellDicts.de
    aspellDicts.en
    ffmpegthumbs
    firefox
    fooyin
    gitMinimal
    kdePackages.akonadi
    kdePackages.akonadi-calendar
    kdePackages.akonadi-contacts
    kdePackages.akonadi-mime
    kdePackages.akonadi-notes
    kdePackages.akonadi-search
    kdePackages.elisa
    kdePackages.kdepim-addons
    kdePackages.kdepim-runtime
    kdePackages.kmail
    kdePackages.kmail-account-wizard
    kdePackages.ksshaskpass
    kdePackages.merkuro
    kdePackages.tokodon
    libreoffice-qt
    nfs-utils
    syncthing
    transmission_4-qt
  ];

  # Enable kdeconnect
  programs.kdeconnect = {
    enable = true;
  };

  # Enable dconf (needed for configuration of gtk themes under wayland)
  programs.dconf.enable = true;

  # Enable ssh-agent
  programs.ssh.startAgent = true;

  system.autoUpgrade.flake = "github:michaelmnemonic/nixos";
  system.stateVersion = "24.05"; # Did you read the comment?
}
