{...}: {
  # Networking with systemd-networkd and iwd
  networking.useNetworkd = true;
  systemd.network.enable = true;
  systemd.network.networks."20-wlan" = {
    matchConfig.Name = "wlan*";
    networkConfig.DHCP = "yes";
  };
  systemd.network.networks."10-lan" = {
    matchConfig.Name = "en*";
    networkConfig.DHCP = "yes";
  };

  networking.wireless.iwd.enable = true;
}
