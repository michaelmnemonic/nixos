{
  config,
  lib,
  ...
}: let
  hostIps = {
    orpheus = "10.0.0.1";
    charon = "10.0.0.2";
    pluto = "10.0.0.3";
    juno = "10.0.0.4";
    flore = "10.0.0.5";
  };
in {
  age.secrets = {
    "${config.networking.hostName}-private.key" = {
      file = ../secrets/${config.networking.hostName}-private.key.age;
      owner = "root";
      group = "root";
    };
    "orpheus_${config.networking.hostName}.psk" = {
      file = ../secrets/orpheus_${config.networking.hostName}.psk.age;
      owner = "root";
      group = "root";
    };
  };

  networking.networkmanager.unmanaged = ["Unterwelt"];
  networking.wireguard.enable = true;
  networking.wireguard.interfaces = {
    Unterwelt = {
      ips = ["${hostIps.${config.networking.hostName}}/24"];
      listenPort = 51820;
      privateKeyFile = config.age.secrets."${config.networking.hostName}-private.key".path;
      peers = [
        # orpheus
        {
          publicKey = "b2D3/C+3yCuzNGW4zYZ8vUMFIO1MUeAp8DoVfjbv3QQ=";
          presharedKeyFile = config.age.secrets."orpheus_${config.networking.hostName}.psk".path;
          allowedIPs = ["10.0.0.0/24"];
          endpoint = "maikkoehler.eu:51820";
          dynamicEndpointRefreshSeconds = 60;
        }
      ];
    };
  };

  networking.extraHosts = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: ip: "${ip} ${name}") hostIps
  );

  networking.firewall.allowedUDPPorts = [51820];
}
