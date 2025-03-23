{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vscodium
  ];

  # VSCode shall use native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
