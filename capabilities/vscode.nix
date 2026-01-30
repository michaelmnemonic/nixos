{
  pkgs,
  ...
}: let
  vscode = pkgs.callPackage ./vscode-package.nix {};
in {
  environment.systemPackages = [
    vscode
  ];

  # VSCode shall use native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
