# nix-tree

A command-line tool for visualizing Nix store dependencies.

## Features

- Interactive terminal UI (TUI) for browsing dependency trees
- SVG export for dependency graphs
- **Supports both store paths and flake references** (e.g., `.#nixosConfigurations.iso`)
- Built with:
  - `petgraph` for graph data structures
  - `ratatui` for terminal UI
  - `svg` for graph rendering
  - Queries Nix store via `nix-store` command

## Usage

### Interactive TUI Mode

View dependencies of a store path:
```bash
nix-tree show /nix/store/path-to-package
```

Or use a flake reference:
```bash
nix-tree show .#nixosConfigurations.iso.config.system.build.vm
nix-tree show .#packages.x86_64-linux.hello
```

Navigate with:
- `↑`/`k` - Move up
- `↓`/`j` - Move down
- `q` - Quit

### SVG Export

Export to SVG using a store path:
```bash
nix-tree svg /nix/store/path-to-package --output graph.svg
```

Or using a flake reference:
```bash
nix-tree svg .#nixosConfigurations.iso.config.system.build.vm --output iso-deps.svg
```

## Building

Using Nix development shell:

```bash
nix develop
cargo build --release
```

Or directly with cargo:

```bash
cargo build --release
```

## Installation

The tool can be built and run from the flake:

```bash
nix develop -c cargo run -- show /nix/store/path
```
