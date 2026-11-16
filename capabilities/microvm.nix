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
    microvm = {
      vms = {
        dev-nix = {
          config = {
            # Set hostname
            networking.hostName = "dev-nix";

            # Use latest stable kernel
            boot.kernelPackages = pkgs.linuxPackages_latest;

            microvm = {
              shares = [
                # Share the host's nix-store to prevent building huge images.
                {
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                  tag = "ro-store";
                  proto = "virtiofs";
                }
              ];
              # Access the vm with ssh via a vsock
              vsock = {
                cid = 3; # must be greater than 2
                ssh.enable = true;
              };
            };

            # TODO: can we access the ssh keys of the hosts config?
            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM1F2ryn8sYFz2SwtPezNMJzFewcZC/WqTY6f6B86vq maik@styx"
            ];

            # NixOS state version
            system.stateVersion = "24.05";
          };
        };
      };
    };
  };
}
