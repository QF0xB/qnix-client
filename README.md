# QNix Client Configuration

This is the SDK-based client configuration. The only initial host is
`QTestVM`, a local QEMU test target for validating the foundational desktop,
ZFS and impermanence configuration before migrating physical machines.

The archived pre-SDK configuration is kept locally in `old/` and ignored by
Git. It is reference material only; do not import it from the new flake.

Host composition lives in `hosts/nixos-hosts.nix`. Shared client defaults are
in `hosts/qnix.nix`; each host has its own `hosts/<name>/qnix.nix` for values
that are specific to that machine and can override the shared defaults.

## QTestVM

`QTestVM` selects the `hyprland`, `impermanence`, and `appearance` profiles.
Those profiles bring their dependencies, including the base system and
workstation configuration. It intentionally excludes the developer profile so
boot and desktop behaviour can be tested without the slower development stack.

Evaluate it with:

```bash
nix flake check
nix build .#nixosConfigurations.QTestVM.config.system.build.toplevel
```

The Disko image path creates `zroot/root@blank` after formatting. The ZFS
feature rolls the root dataset back to that snapshot at boot; `/persist`,
`/cache`, and `/nix` are separate datasets and survive the reset.
