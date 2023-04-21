# arrpc-flake

A nixos-flake for the [arRPC](https://github.com/OpenAsar/arrpc) project. The flake exposes the `arrpc` package that you can use.



## Usage


1. Add this repository to your inputs

```nix
# ...
inputs = {
  arrpc = {
    url = "github:notashelf/arrpc-flake";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
# ...
```

2. Reference the exposed package from the input

```nix
# with home-manager
home.packages [
  inputs.arrpc.packages.${pkgs.system}.arrpc # arrpc and default both refer to the same derivation
  # ...
];
```

3. Start arRPC with a systemd-service 

```nix
let
  arRPC = inputs.arrpc.packages.${pkgs.system}.arrpc;
in {
  systemd.user.services = {
    arRPC = mkService {
      Unit.Description = "Discord Rich Presence for browsers, and some custom clients";
        Service = {
            ExecStart = "${lib.getExe arRPC}";
            Restart = "always";
        };
      };
    };
  };
}
```
