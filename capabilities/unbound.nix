{...}: {
  services.unbound = {
    enable = true;
    enableRootTrustAnchor = true;
    settings = {
      server = {
        interface = ["127.0.0.1"];
        port = 5335;
        access-control = ["127.0.0.1 allow"];
        # Based on recommended settings in https://docs.pi-hole.net/guides/dns/unbound/#configure-unbound
        harden-glue = true;
        harden-dnssec-stripped = true;
        use-caps-for-id = false;
        prefetch = true;
        edns-buffer-size = 1232;
      };
      forward-zone = [
        # Example config with quad9
        {
          name = ".";
          forward-addr = [
            "9.9.9.9#dns.quad9.net"
            "149.112.112.112#dns.quad9.net"
          ];
          forward-tls-upstream = true; # Protected DNS
        }
      ];
      remote-control.control-enable = true;
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      dns = "none";
      insertNameservers = ["127.0.0.1"];
    };
    nameservers = ["127.0.0.1"];
  };
}
