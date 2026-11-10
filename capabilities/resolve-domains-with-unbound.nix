{...}: {
  # Use unbound with dns-over-tls
  services.unbound = {
    enable = true;
    enableRootTrustAnchor = true;
    resolveLocalQueries = true;
    settings = {
      server = {
        interface = [
          "127.0.0.1"
        ];
        access-control = [
          "127.0.0.1 allow"
        ];
        # Enable RPZ
        module-config = "'respip validator iterator'";
        # Add some more privacy (RFC7816)
        qname-minimisation = true;
      };
      forward-zone = [
        {
          name = "\".\"";
          forward-tls-upstream = true;
          forward-addr = [
            "1.1.1.1@853"
            "1.0.0.1@853"
            "2606:4700:4700::1111@853"
            "2606:4700:4700::1001@853"
          ];
        }
      ];
      rpz = [
        {
          # Block ads and some malware
          name = "hageziPro";
          url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/rpz/pro.txt";
        }
      ];
    };
  };

  # Domains are resolved using unbound
  services.resolved.enable = false;
}
