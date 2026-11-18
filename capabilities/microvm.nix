{
  config,
  lib,
  microvm,
  pkgs,
  vscode-server,
  ...
}: let
  cfg = config.universe.microvm;
in {
  imports = [
    microvm.nixosModules.host
  ];
  options.universe.microvm = {
    enable = lib.mkEnableOption "Several microvms michaelmnemonic finds useful";
  };
  config = lib.mkIf cfg.enable {
    microvm = {
      vms = {
        dev-nix = {
          config = {
            imports = [
              vscode-server.nixosModules.default
            ];

            # Set hostname
            networking.hostName = "dev-nix";

            # Use latest stable kernel
            boot.kernelPackages = pkgs.linuxPackages_latest;

            networking.useNetworkd = true;

            systemd.network.networks."20-lan" = {
              matchConfig.Type = "ether";
              networkConfig = {
                DHCP = "yes";
              };
            };

            environment.etc."tmpfiles.d/root.conf".text = ''
              d /root/Projekte 0750 root root -
            '';

            microvm = {
              interfaces = [
                {
                  type = "user";
                  id = "dev-nix";
                  mac = "02:00:00:00:00:01";
                }
              ];
              shares = [
                # Share the host's nix-store to prevent building huge images.
                {
                  source = "/nix/store";
                  mountPoint = "/nix/.ro-store";
                  tag = "ro-store";
                  proto = "virtiofs";
                }
                # Share vscode server volume to prevent multiple remote server installs
                {
                  source = "/var/lib/microvm-storage/vscode-server";
                  mountPoint = "/root/.vscode-server";
                  tag = "vscode-server";
                  proto = "virtiofs";
                }
                # Share zed server volume to prevent multiple remote server installs
                {
                  source = "/var/lib/microvm-storage/zed_server";
                  mountPoint = "/root/.zed_server";
                  tag = "zed_server";
                  proto = "virtiofs";
                }
              ];
              # Access the vm with ssh via a vsock
              vsock = {
                cid = 3; # must be greater than 2
                ssh.enable = true;
              };
            };

            environment.systemPackages = with pkgs; [
              alejandra
              git
              nil
            ];

            services.openssh = {
              enable = true;
              openFirewall = true;
              settings = {
                PasswordAuthentication = false;
                KbdInteractiveAuthentication = false;
                AllowAgentForwarding = "yes";
                PermitRootLogin = "yes";
              };
            };

            # TODO: can we access the ssh keys of the hosts config?
            users.users.root.openssh.authorizedKeys.keys = [
              "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINM1F2ryn8sYFz2SwtPezNMJzFewcZC/WqTY6f6B86vq maik@styx"
            ];

            # Make vscode's remote server compatible with this host
            services.vscode-server.enable = true;
            systemd.user.services.auto-fix-vscode-server.wantedBy = ["default.target"];

            # Allow unpatched binaries to execute
            programs.nix-ld.enable = true;

            # NixOS state version
            system.stateVersion = "24.05";
          };
        };
      };
    };

    # Make sure shared volumes exist
    environment.etc."tmpfiles.d/microvm-storage.conf".text = ''
      d /var/lib/microvm-storage 755 microvm kvm\n
      v /var/lib/microvm-storage/vscode-server 755 microvm kvm\n
      v /var/lib/microvm-storage/zed_server 755 microvm kvm\n
    '';

    # Provide a human friendly name
    programs.ssh.extraConfig = ''
      Host dev-nix
        HostName vsock/${toString config.microvm.vms.dev-nix.config.config.microvm.vsock.cid}
        User root
        ProxyCommand ${pkgs.systemd}/lib/systemd/systemd-ssh-proxy %h %p
        ProxyUseFdpass yes
        CheckHostIP no
        ForwardAgent yes
        AddKeysToAgent yes
    '';
  };
}
