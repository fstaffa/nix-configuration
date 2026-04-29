{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.myDesktop.opensnitch.enable = lib.mkEnableOption "OpenSnitch application firewall";

  config = lib.mkIf config.myDesktop.opensnitch.enable {
    services.opensnitch = {
      enable = true;
      settings = {
        DefaultAction = "allow";
        ProcMonitorMethod = "ebpf";
        InterceptUnknown = true;
        Firewall = "nftables";
      };
      rules = {
        nix = {
          name = "nix";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.nix}/bin/nix";
          };
        };
        syncthing = {
          name = "syncthing";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.syncthing}/bin/syncthing";
          };
        };
        firefox = {
          name = "firefox";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${pkgs.firefox}/lib/firefox/firefox";
          };
        };
        avahi-daemon = {
          name = "avahi-daemon";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.avahi}/bin/avahi-daemon";
          };
        };
        claude = {
          name = "claude";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.claude-code}/bin/claude";
          };
        };
        slack = {
          name = "slack";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${pkgs.slack}/lib/slack/slack";
          };
        };
        systemd-timesyncd = {
          name = "systemd-timesyncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${pkgs.systemd}/lib/systemd/systemd-timesyncd";
          };
        };
        nsncd = {
          name = "nsncd";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.nsncd}/bin/nsncd";
          };
        };
        ssh = {
          name = "ssh";
          enabled = true;
          action = "allow";
          duration = "always";
          operator = {
            type = "simple";
            sensitive = false;
            operand = "process.path";
            data = "${lib.getBin pkgs.openssh}/bin/ssh";
          };
        };
      };
    };
  };
}
