{...}: {
  systemd.user.enable = true;
  systemd.user.services.synthing.enable = true;
  home.stateVersion = "24.05";
}
