{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.programs.openshell;
  tomlFormat = pkgs.formats.toml { };

  defaultSettings = {
    openshell = {
      version = 2;
      gateway = {
        bind_address = "127.0.0.1:17670";
        log_level = "info";
        compute_driver = "docker";
      };
      drivers.docker = {
        socket_path = "/var/run/docker.sock";
        image_pull_policy = "if_not_present";
        sandbox_label = "openshell";
      };
    };
  };

  # Not linked into ~/.config: the gateway rejects a symlinked gateway.toml,
  # so the unit points OPENSHELL_GATEWAY_CONFIG at the store file instead.
  gatewayConfig = tomlFormat.generate "openshell-gateway.toml" (
    recursiveUpdate defaultSettings cfg.settings
  );
in
{
  options.programs.openshell = {
    enable = mkEnableOption "NVIDIA OpenShell agent sandbox runtime (CLI + gateway user service)";

    package = mkOption {
      type = types.package;
      default = pkgs.openshell;
      description = "The openshell package (must provide openshell and openshell-gateway)";
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      description = "Gateway TOML settings, merged over the Docker-driver defaults";
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    home.sessionVariables.OPENSHELL_TELEMETRY_ENABLED = "false";

    # Mirrors upstream deploy/deb/openshell-gateway.service
    systemd.user.services.openshell-gateway = {
      Unit = {
        Description = "OpenShell Gateway";
        Documentation = "https://github.com/NVIDIA/OpenShell";
      };
      Service = {
        Type = "simple";
        StateDirectory = "openshell/gateway";
        Environment = [
          "OPENSHELL_LOCAL_TLS_DIR=%h/.local/state/openshell/tls"
          "OPENSHELL_GATEWAY_CONFIG=${gatewayConfig}"
          "OPENSHELL_TELEMETRY_ENABLED=false"
        ];
        ExecStartPre = [
          "${cfg.package}/bin/openshell-gateway config preflight"
          "${cfg.package}/bin/openshell-gateway generate-certs --output-dir \${OPENSHELL_LOCAL_TLS_DIR} --server-san host.openshell.internal"
        ];
        ExecStart = "${cfg.package}/bin/openshell-gateway";
        Restart = "on-failure";
        RestartSec = "5s";
        PrivateTmp = true;
        UMask = "0077";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
