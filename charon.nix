{pkgs, lib, ...}: {
  imports = [
    ./_shared/common.nix
    ./services/audio.nix
    ./services/chipcards.nix
    ./services/printing.nix
    ./services/scanning.nix
    ./users/maik.nix
  ];

  # Set hostname
  networking.hostName = "charon";

  # Use latest stable kernel
  boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

  # Use correct devicetree
  hardware = {
    deviceTree = {
      enable = true;
      name = "/dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb";
      filter = "*sc8280xp-lenovo-thinkpad-x13s.dtb";
    };
  };

  # Copy device tree on EFI partition
  boot.loader.systemd-boot.installDeviceTree = true;

  boot.kernelParams = [
    "dtb=/dtbs/qcom/sc8280xp-lenovo-thinkpad-x13s.dtb"
    "arm64.nopauth"
    "clk_ignore_unused"
    "pd_ignore_unused"
  ];

  # Use zram as swap
  zramSwap = {
    enable = true;
    algorithm = "zstd";
  };

  # Enable plymouth
  boot.plymouth.enable = true;

  # Use german keyboard layout
  services.xserver = {
    enable = true;
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

  # https://github.com/jhovold/linux/wiki/X13s#modem
  networking.networkmanager.fccUnlockScripts = [
      {
        id = "105b:e0c3";
        path = "${pkgs.modemmanager}/share/ModemManager/fcc-unlock.available.d/105b";
      }
    ];

  # Disable NetworkManager wait online
  systemd.services."NetworkManager-wait-online".enable = false;

  # Enable mDNS
  services.avahi.enable = true;

  # Add inter, jetbrains-mono and noto fonts
  fonts.packages = with pkgs; [
    inter
    jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans
    noto-fonts-emoji
  ];

  # List of system-wide packages
  environment.systemPackages = with pkgs; [
    aspell
    aspellDicts.de
    aspellDicts.en
    ffmpegthumbs
    firefox
    gitMinimal
  ];

  system.stateVersion = "24.05";
}
