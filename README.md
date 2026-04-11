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

These helpers are installed when your NixOS config sets `qnix.system.shell.projectRoot`
to this client repo (and `qnixAliases` is enabled). They rewrite `flake.nix` only inside
the `qnix-modules` block marked with `# Managed by qnix-dev-modules and qnix-use-release.`

### Release helpers — command reference

| Command | Purpose |
|--------|---------|
| `qnix-release` | In the **modules** repo: bump or set version, commit `VERSION`, tag `vX.Y.Z`, push, then point the **client** flake at that release. |
| `qnix-use-release` | Point the **client** flake at an **existing** `qnix-modules` version (no tag, no push). |
| `qnix-dev-modules` | Point the **client** at a **local** checkout: `path:$QNIX_ROOT/modules`. Runs `nix flake update qnix-modules`. |
| `qnix-sync-modules` | Re-run `nix flake update qnix-modules` for whatever `qnix-modules` URL is already in `flake.nix`. |

**Shared flags** (`qnix-release` and `qnix-use-release` only):

- `--source flakehub` or `--source github` (also `--source=…`).  
  Default: **`flakehub`**, or override with env `QNIX_MODULES_RELEASE_SOURCE=flakehub|github`.

**URL shapes** (defaults; override with env if needed):

- `flakehub` → `https://flakehub.com/f/QF0xB/qnix-modules/=X.Y.Z`  
  (`QNIX_MODULES_FLAKEHUB_PREFIX` replaces the base URL without the `/=version` suffix.)
- `github` → `github:QF0xB/qnix-modules?ref=vX.Y.Z`  
  (`QNIX_MODULES_GITHUB_PREFIX` replaces `github:QF0xB/qnix-modules`.)

---

`qnix-use-release` **requires one argument**: a version `X.Y.Z` or `vX.Y.Z`.

```bash
qnix-use-release 0.1.0
qnix-use-release --source github 0.1.0
```

---

`qnix-release` **optional first argument** (default **`patch`** if omitted):

| Argument | Meaning |
|----------|---------|
| `major` | Bump major from `modules/VERSION` (`modules` repo must be clean). |
| `minor` | Bump minor. |
| `patch` | Bump patch (default). |
| `X.Y.Z` or `vX.Y.Z` | Use that exact version instead of bumping (tag must not already exist). |

Examples:

```bash
qnix-release                    # same as qnix-release patch
qnix-release patch
qnix-release minor
qnix-release 1.2.3              # release exactly v1.2.3
qnix-release --source github patch
```

Behavior after rewriting the client:

- **`--source github`**: runs `nix flake update qnix-modules` immediately (the git tag exists on GitHub).
- **Default (`flakehub`)**: does **not** lock yet — FlakeHub gets the version after CI. When publish is green, run `nix flake update qnix-modules` in this repo and commit `flake.lock`.

`qnix-release` requires a **clean** git working tree in the **modules** repository.

---

### Using local `qnix-modules` (manual)

You can also set the input by hand:

```nix
qnix-modules = {
  url = "path:../qnix-modules";
};
```

Or use `qnix-dev-modules` to switch the managed block to the local path (see table above).

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
