{
  config,
  lib,
  microvm,
  pkgs,
  vscode-server,
  agenix,
  ...
}: let
  cfg = config.universe.microvm;

  # SSH ProxyCommand that boots dev-nix on demand: starts the VM if it
  # isn't running, waits for the guest's sshd, then hands the connection
  # to ssh via systemd-ssh-proxy (fd passing).
  dev-nix-ssh-proxy = pkgs.writeShellScriptBin "dev-nix-ssh-proxy" ''
    set -eu
    ${pkgs.systemd}/bin/systemctl start microvm@dev-nix.service

    for i in {1..120}; do
      ${pkgs.systemd}/lib/systemd/systemd-ssh-proxy "$@" 2>/dev/null && exit 0
      ${pkgs.coreutils}/bin/sleep 0.5
    done

    echo "dev-nix: SSH did not become reachable; check systemctl status microvm@dev-nix.service" >&2
    exit 1
  '';
in {
  imports = [
    microvm.nixosModules.host
  ];
  options.universe.microvm = {
    enable = lib.mkEnableOption "Several microvms michaelmnemonic finds useful";
  };
  config = lib.mkIf cfg.enable {
    age.secrets = {
      "dev-nix-host.key" = {
        file = ../secrets/dev-nix-host.key.age;
        owner = "microvm";
        group = "kvm";
      };
    };
    microvm = {
      vms = {
        dev-nix = {
          # Booted on demand by the dev-nix SSH ProxyCommand
          autostart = false;
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
              credentialFiles = {
                ssh_host_ed25519_key = config.age.secrets."dev-nix-host.key".path;
              };
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
              pi-coding-agent
            ];

            services.openssh = {
              enable = true;
              openFirewall = true;
              # Never generate a random key: the identity must stay stable
              generateHostKeys = false;
              hostKeys = [
                {
                  path = "/run/credentials/@system/ssh_host_ed25519_key";
                  type = "ed25519";
                }
              ];
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

    environment.systemPackages = [dev-nix-ssh-proxy];

    # Allow wheel to manage the dev-nix VM without a password so the
    # SSH ProxyCommand can boot it on demand
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "microvm@dev-nix.service" &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';

    # Provide a human friendly name
    programs.ssh.extraConfig = ''
      Host dev-nix
        HostName vsock/${toString config.microvm.vms.dev-nix.config.config.microvm.vsock.cid}
        User root
        ProxyCommand ${dev-nix-ssh-proxy}/bin/dev-nix-ssh-proxy %h %p
        ProxyUseFdpass yes
        CheckHostIP no
        ForwardAgent yes
        AddKeysToAgent yes
    '';

    # Configure git
    programs.git = {
      enable = true;
      config.user = {
        name = "michaelmnemonic";
        email = "michaelmnemonic@posteo.eu";
      };
    };
  };
}
