# nix-tree

A command-line tool for visualizing Nix store dependencies.

## Features

- Interactive terminal UI (TUI) for browsing dependency trees
- SVG export for dependency graphs
- Built with:
  - `petgraph` for graph data structures
  - `ratatui` for terminal UI
  - `svg` for graph rendering
  - Queries Nix store via `nix-store` command

## Usage

### Interactive TUI Mode

```bash
nix-tree show /nix/store/path-to-package
```

Navigate with:
- `↑`/`k` - Move up
- `↓`/`j` - Move down
- `q` - Quit

### SVG Export

```bash
nix-tree svg /nix/store/path-to-package --output graph.svg
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
