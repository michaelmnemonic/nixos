{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
let
  cfg = config.capabilities.llama-cpp;
  llama-cpp-pkg =
    if cfg.rocmSupport then pkgs.llama-cpp.override { rocmSupport = true; } else pkgs.llama-cpp;
in
{
  options.capabilities.llama-cpp = {
    enable = mkEnableOption "llama.cpp server";
    rocmSupport = mkOption {
      type = types.bool;
      default = false;
      description = "Enable ROCm support for GPU acceleration";
    };
    port = mkOption {
      type = types.port;
      default = 8080;
      description = "Public port to listen on";
    };
    internalPort = mkOption {
      type = types.port;
      default = 8081;
      description = "Internal port for llama-server";
    };
    modelHf = mkOption {
      type = types.str;
      default = "ggml-org/gpt-oss-20b-GGUF";
      description = "HuggingFace model to use";
    };
    idleTimeout = mkOption {
      type = types.int;
      default = 90;
      description = "Idle timeout in seconds before server shuts down";
    };
    apiKeyFile = mkOption {
      type = types.nullOr types.path;
      default = null;
      description = "Path to a file containing the API key";
    };
  };

  config = mkIf cfg.enable {
    systemd.sockets.llama-cpp = {
      description = "Socket for llama.cpp server";
      wantedBy = [ "sockets.target" ];
      socketConfig = {
        ListenStream = "${toString cfg.port}";
        # Redirect to the proxy service
        Service = "llama-cpp-proxy.service";
      };
    };

    systemd.services.llama-cpp-proxy = {
      description = "Proxy for llama.cpp server socket activation";
      # The proxy should stop if the server stops
      bindsTo = [ "llama-cpp.service" ];
      # Start the server if it's not running
      requires = [ "llama-cpp.service" ];
      after = [ "llama-cpp.service" ];
      serviceConfig = {
        ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:${toString cfg.internalPort} --exit-idle-time=${toString cfg.idleTimeout}";
      };
    };

    systemd.services.llama-cpp = {
      description = "llama.cpp server";
      serviceConfig = {
        ExecStart = "${llama-cpp-pkg}/bin/llama-server --jinja -hf ${cfg.modelHf} --port ${toString cfg.internalPort}${
          optionalString (cfg.apiKeyFile != null) " --api-key-file ${cfg.apiKeyFile}"
        }";
        # Persistent cache for models downloaded via -hf
        CacheDirectory = "llama-cpp";
        Environment = [
          "LLAMA_CACHE=/var/cache/llama-cpp"
        ]
        ++ (lib.optional cfg.rocmSupport "LD_LIBRARY_PATH=/run/opengl-driver/lib");
        DynamicUser = true;
        # We don't want it to restart automatically; the proxy/socket will handle it
        Restart = "no";
      };
    };
  };
}
