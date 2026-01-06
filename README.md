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

### Building

```bash
# Build a specific host
nix build .#nixosConfigurations.MyHost.config.system.build.toplevel

# Test evaluation
nix eval .#nixosConfigurations.MyHost.options
```

## Host Factory Parameters

The `mkNixosConfiguration` function accepts:

- `host` (required): Host name (directory name)
- `user` (default: `"q.braendli"`): Username
- `isVm` (default: `false`): Whether this is a VM
- `isInstall` (default: `false`): Whether this is an install ISO
- `isLaptop` (default: `false`): Whether this is a laptop
- `isNixOS` (default: `true`): Whether this is NixOS
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

