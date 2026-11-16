{
  config,
  lib,
  microvm,
  pkgs,
  ...
}: let
  cfg = config.universe.microvm;
in {
  imports = [microvm.nixosModules.host];
  options.universe.microvm = {
    enable = lib.mkEnableOption "Several microvms michaelmnemonic finds useful";
  };
  config = lib.mkIf cfg.enable {
    microvm.vms = {
      dev-nix = {
        config = {
          # Set hostname
          networking.hostName = "dev-nix";

          # Use latest stable kernel
          boot.kernelPackages = pkgs.linuxPackages_latest;

          # Share the host's nix-store to prevent building huge images.
          microvm.shares = [
            {
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
              proto = "virtiofs";
            }
          ];
          # NixOS state version
          system.stateVersion = "24.05";
        };
      };
    };
  };
}
