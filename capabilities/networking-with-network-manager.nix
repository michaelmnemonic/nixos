{...}: {
  # networking with network-manager
  networking.networkmanager.enable = true;
  systemd.services."NetworkManager-wait-online".enable = false;
}
