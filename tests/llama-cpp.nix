{ pkgs ? import <nixpkgs> {} }:

pkgs.testers.nixosTest {
  name = "llama-cpp-socket-activation";
  nodes.machine = { config, pkgs, ... }: {
    imports = [ ../capabilities/llama-cpp.nix ];
    
    capabilities.llama-cpp = {
      enable = true;
      port = 8080;
      internalPort = 8081;
      idleTimeout = 2;
      apiKeyFile = pkgs.writeText "api-key" "secret-key";
    };

    # Mock llama-cpp package
    nixpkgs.overlays = [ (self: super: {
      llama-cpp = pkgs.runCommand "mock-llama-cpp" {} ''
        mkdir -p $out/bin
        cat <<INNER > $out/bin/llama-server
#!/bin/sh
echo "Mock llama-server starting with args: \$@"
# Check if --api-key-file is present and contains the right value
case "\$*" in
  *"--api-key-file /nix/store/"*) 
    echo "API key file check passed"
    ;;
  *)
    echo "API key file check failed" >&2
    exit 1
    ;;
esac

# Use socat for more reliable mock server
${pkgs.socat}/bin/socat TCP-LISTEN:8081,fork,reuseaddr EXEC:"echo 'HTTP/1.1 200 OK\n\nhello'"
INNER
        chmod +x $out/bin/llama-server
      '';
    }) ];
    
    environment.systemPackages = [ pkgs.netcat pkgs.socat ];
  };

  testScript = ''
    machine.wait_for_unit("llama-cpp.socket")
    
    # Check that service is not running yet
    machine.fail("systemctl is-active llama-cpp.service")
    
    # Trigger socket activation via proxy
    machine.wait_until_succeeds("echo 'GET /' | nc -w 1 localhost 8080 | grep hello", timeout=30)
    
    # Check that service is now running
    machine.wait_for_unit("llama-cpp.service")
    
    # Check logs for API key confirmation
    machine.succeed("journalctl -u llama-cpp.service | grep 'API key file check passed'")
    
    # Stop the service to finish test
    machine.succeed("systemctl stop llama-cpp.service")
  '';
}
