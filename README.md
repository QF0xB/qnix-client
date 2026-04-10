# QNix Client Configuration

Bleeding-edge desktop/laptop configuration using `nixos-unstable`. Contains host-specific config and secrets for client machines.

## Structure

```
qnix-client/
├── flake.nix              # Main flake with inputs and outputs
├── hosts/
│   ├── nixos-hosts.nix    # Host factory function
│   └── {host-name}/
│       ├── configuration.nix  # Host-specific NixOS config
│       ├── hardware.nix        # Hardware-specific config
│       ├── home.nix            # Host-specific Home Manager config
│       └── qnix.nix            # QNix module options (qnix.*)
└── README.md
```

## Quick Start

1. **Add your host** to `hosts/nixos-hosts.nix`:
   ```nix
   {
     MyHost = mkNixosConfiguration "MyHost" { };
     MyHost-install = mkNixosConfiguration "MyHost" { isInstall = true; };
   }
   ```

2. **Create host directory**:
   ```bash
   mkdir -p hosts/MyHost
   ```

3. **Create host files**:
   - `hosts/MyHost/configuration.nix` - Basic NixOS config
   - `hosts/MyHost/hardware.nix` - Hardware config
   - `hosts/MyHost/home.nix` - Home Manager config (optional)
   - `hosts/MyHost/qnix.nix` - QNix module options

4. **Enable modules** in `hosts/MyHost/qnix.nix`:
   ```nix
   {
     qnix = {
       firefox.enable = true;
       terminal.enable = true;
       hyprland.enable = true;
       # ...
     };
   }
   ```

5. **Build and switch**:
   ```bash
   sudo nixos-rebuild switch --flake .#MyHost
   ```

## Categories

This repository uses `categories = ["core", "desktop"]`, which means:
- **Core modules**: Always loaded (sops, user, etc.)
- **Desktop modules**: Desktop-specific (hyprland, ags, firefox, etc.)

## Development

### Using Local qnix-modules

During development, you can use a local path for `qnix-modules`:

```nix
qnix-modules = {
  url = "path:../qnix-modules";
};
```

If your shell profile includes the QNix helper tools, you can switch sources with:

```bash
qnix-dev-modules
qnix-use-release v0.1.0
qnix-sync-modules
```

To cut a release from the `modules` repo and switch the client to that tag:

```bash
qnix-release patch
```

`qnix-release` expects clean `modules` and `client` git trees. It bumps `modules/VERSION`,
creates and pushes a `vX.Y.Z` tag, then rewrites the client input and refreshes
`client/flake.lock`. By default it uses `github:QF0xB/qnix-modules?ref=<tag>` as the
release source. Set `QNIX_MODULES_RELEASE_PREFIX` if you want to point the client
at a FlakeHub source instead.

### Building

```bash
# Build a specific host
nix build .#nixosConfigurations.MyHost.config.system.build.toplevel

# Test evaluation
nix eval .#nixosConfigurations.MyHost.options
```

### Evaluation Performance

When profiling eval changes in `qnix-modules`, use an input override so the client flake picks up local module edits without touching `flake.lock`:

```bash
# Fast host-level eval timing
time nix eval --no-write-lock-file \
  --override-input qnix-modules path:/home/q.braendli/projects/qnix/modules \
  --raw .#nixosConfigurations.QFrame13.config.system.name >/dev/null

# Heavier VM eval timing (includes vm derivation path eval)
time nix eval --no-write-lock-file \
  --override-input qnix-modules path:/home/q.braendli/projects/qnix/modules \
  --raw .#nixosConfigurations.QConfigVM.config.system.build.vm.drvPath >/dev/null
```

If eval is unexpectedly slow, generate and inspect `flamegraph.svg` and focus first on large `derivationStrict:*`, `home-manager-files`, and `modules.nix` stack regions.

## Host Factory Parameters

The `mkNixosConfiguration` function accepts:

- `host` (required): Host name (directory name)
- `user` (default: `"q.braendli"`): Username
- `isVm` (default: `false`): Whether this is a VM
- `isInstall` (default: `false`): Whether this is an install ISO
- `isLaptop` (default: `false`): Whether this is a laptop
- `isNixOS` (default: `true`): Whether this is NixOS
- `categories` (default: inherited from `specialArgs.defaultCategories`): Module categories to load for this host
- `loadOptions` (default: `true`): Whether to import category option modules
- `extraConfig` (default: `{}`): Additional NixOS modules

## Special Args

The following are available in all modules via `specialArgs`:

- `inputs`: All flake inputs
- `categories`: `["core", "desktop"]`
- `host`: Current host name
- `user`: Username
- `isVm`, `isInstall`, `isLaptop`, `isNixOS`: Host flags
- `dots`: Path to dotfiles (`/persist/home/${user}/projects/dotfiles`)

## See Also

- [qnix-modules](../qnix-modules/) - Module definitions
- [example-host](hosts/example-host/) - Example host configuration
