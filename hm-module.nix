self: {
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types;
  cfg = config.programs.arrpc;
in {
  options = {
    programs.arrpc = {
      enable = lib.mkEnableOption "arrpc";

      package = lib.mkOption {
        type = types.package;
        default = self.packages.${pkgs.system}.default;
        description = lib.mdDoc ''
          Package to use for arRPC configuration.
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

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      # add the package
      home.packages = [cfg.package];
    }
  ]);
}
