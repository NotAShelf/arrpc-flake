# arrpc-flake

A nixos-flake for the [arRPC](https://github.com/OpenAsar/arrpc) project. The flake exposes the `arrpc` package that you can use.
This flake is only responsible for providing arRPC to you. You will still need to set up arRPC [for your respective client](https://github.com/OpenAsar/arrpc#usage).



## Usage


### 1. Add this repository to your inputs

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

### 2. Reference the exposed package from the input

```nix
# with home-manager
home.packages = [
  inputs.arrpc.packages.${pkgs.system}.arrpc # arrpc and default both refer to the same derivation
  # ...
];
```

### 3.a Start arRPC with a systemd service

You can use a systemd service to start arRPC automatically

```nix
{lib, ...}:
let
  arRPC = inputs.arrpc.packages.${pkgs.system}.arrpc;
  
  # start arRPC after your window manager/wayland compositor
  mkService = lib.recursiveUpdate {
    Unit.PartOf = ["graphical-session.target"];
    Unit.After = ["graphical-session.target"];
    Install.WantedBy = ["graphical-session.target"];
  };
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

### 3.b Start arRPC from your window manager/compositor's auto-start line

Alternatively, if you are not a big fan of systemd services, you can auto-start arRPC from your wm/compositor's autostart section

```nix
# For Hyprland - requires arRPC to be in your environment.packages or home.packages
exec-once = arRPC
```

## Overriding

You can pass custom flags to the arRPC binary by overriding the package with an `extraFlags` attribute that takes a list.

```nix
arrpc = inputs.arrpc.packages.${pkgs.system}.arrpc.override {
  extraFlags = ["--debug"];
};
```
