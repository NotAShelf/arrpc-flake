self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types mkIf mkOption mkEnableOption mdDoc literalExpression;

  cfg = config.services.arrpc;
in {
  options.services.arrpc = {
    enable = mkEnableOption "arrpc";

    package = mkOption {
      type = types.package;
      default = self.packages.${pkgs.system}.default;
      description = mdDoc ''
        Package to use for arRPC configuration.
      '';
      example = literalExpression ''
        inputs.arrpc.packages.''${pkgs.system}.arrpc.override {
          flags = [
            "--debug"
          ];
        }
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services = {
      arRPC = {
        Unit = {
          Description = "Discord Rich Presence for browsers, and some custom clients";
          After = ["graphical-session.target"];
          PartOf = ["graphical-session.target"];
        };

        Install.WantedBy = ["graphical-session.target"];

        Service = {
          ExecStart = "${lib.getExe cfg.package}";
          Restart = "always";
        };
      };
    };
  };
}
