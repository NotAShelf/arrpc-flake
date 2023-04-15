{
  description = "WebCord Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    dream2nix = {
      url = "github:nix-community/dream2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    inherit (nixpkgs) lib;

    supportedSystems = [
      "aarch64-linux"
      "x86_64-linux"

      # open an issue if you want these
      #"aarch64-darwin"
      #"x86_64-darwin"
    ];
    genSystems = lib.genAttrs supportedSystems;

    wrapper = system: old: config: let
      pkgs = nixpkgs.legacyPackages.${system};
      arrpc-wrapped =
        pkgs.runCommand "${old.name}-wrapped"
        {
          inherit (old) pname version meta;

          nativeBuildInputs = [pkgs.makeWrapper];
          makeWrapperArgs = config.makeWrapperArgs or [];
        }
        ''
          mkdir -p $out
          cp -r --no-preserve=mode,ownership ${old}/* $out/
          chmod +x "$out/bin/arRPC"
          makeWrapper "$out/bin/arRPC" ''${makeWrapperArgs[@]} ${
            lib.optionalString ((config.flags or []) != [])
            (lib.concatStringsSep " " (map (flag: "--add-flags ${flag}") config.flags))
          }
        '';
    in
      arrpc-wrapped // {override = wrapper system old;};
  in {
    packages = genSystems (system: {
      arrpc-wrapped = wrapper system self.packages.${system}.arrpc {};
      arrpc = nixpkgs.legacyPackages.${system}.callPackage ./packages/arrpc.nix {};
      default = self.packages.${system}.arrpc-wrapped;
    });

    homeManagerModules = {
      arrpc = import ./hm-module.nix self;
      default = self.homeManagerModules.arrpc;
    };

    overlays = {
      arrpc = _: prev: {
        arrpc = self.packages.${prev.system}.arrpc;
      };
      default = self.overlays.arrpc;
    };

    formatter = genSystems (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}
