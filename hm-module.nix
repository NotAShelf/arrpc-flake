self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types mkOption mkEnableOption;
  cfg = config.services.arrpc;

  mkService = lib.recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
in {
  options = {
    services.arrpc = {
      enable = mkEnableOption cfg.package.meta.description;

      package = mkOption {
        type = types.package;
        default = self.packages.${pkgs.system}.default;
        description = lib.mdDoc ''
          Package to use for arRPC service.
        '';
        example = lib.literalExpression ''
          inputs.arrpc.packages.''${pkgs.system}.arrpc.override {
            flags = [
              "--debug"
            ];
          }
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    # add the package
    home.packages = [cfg.package];

    # start the systemd service as user in the background
    systemd.user.services = {
      arRPC = mkService {
        Unit.Description = "Local implementation of Discord's RPC servers";
        Service = {
          # use the selected package
          ExecStart = "${lib.getExe cfg.package}";
          Restart = "always";
        };
      };
    };
  };
}
