# arrpc-flake

A nixos-flake for the [arRPC](https://github.com/OpenAsar/arrpc) project. The flake exposes the `arrpc` package that you can use.

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

### 3.a Use the home-manager module

We provide a home-manager module that does the heavy lifting for you.

```nix
{
  pkgs,
  lib,
  inputs,
  ...
}:
with lib; {
  imports = [
    inputs.arrpc.homeManagerModules.default
  ];

  config =  {
    home.packages = [
      pkgs.webcord-vencord # webcord with vencord extension installed
    ];

    # enable arRPC service, adds arRPC to home-packages and starts the systemd service for you
    services.arrpc.enable = true;
  };
}


```

### 3.b Start arRPC with a systemd service

You can use a systemd service to start arRPC automatically

```nix
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

### 3.c Start arRPC from your window manager/compositor's auto-start line

Alternatively, if you are not a big fan of systemd services, you can auto-start arRPC from your wm/compositor's autostart section

```nix
# For Hyprland - requires arRPC to be in your environment.systemPackages or home.packages
exec-once = arRPC
```
