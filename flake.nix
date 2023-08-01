{
  description = "arRPC Nix Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = [
      "aarch64-linux"
      "x86_64-linux"
      "aarch64-darwin"
      "x86_64-darwin"
    ];

    withPkgsFor = fn: nixpkgs.lib.genAttrs supportedSystems (system: fn system nixpkgs.legacyPackages.${system});
  in {
    homeManagerModules = rec {
      arrpc = import ./hm-module.nix self;
      default = arrpc;
    };

    packages = withPkgsFor (_: pkgs: rec {
      arrpc = pkgs.callPackage ./package.nix {};
      default = arrpc;
    });

    formatter = withPkgsFor (_: pkgs: pkgs.alejandra);
  };
}
