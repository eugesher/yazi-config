# yazi-config

Configuration of the [Yazi](https://github.com/sxyazi/yazi) terminal file
manager: the Catppuccin Mocha flavor on the terminal's own background.

## Requirements

- **Yazi 25.5.28+** with its `ya` CLI. The `[mgr]` theme section and the
  `ya pkg` package manager appeared in that release; `install.sh` checks the
  version.
- **git and network access to GitHub.** `ya pkg` clones the packages.
- **A true-color terminal.** The flavor uses hex colors.
- **A Nerd Font (v3).** Icons and the rounded ends of the status-bar segments.

## Installation

```bash
./install.sh
```

The script checks the Yazi version, backs an existing `~/.config/yazi` up to
`~/.config/yazi.backup.<timestamp>`, copies `yazi/` into its place and runs
`ya pkg upgrade` there, so every package comes in its latest version. Run it
again to update the packages.

Edit the files in the repository and reinstall — an edit made in
`~/.config/yazi` is lost on the next install. When `YAZI_CONFIG_HOME` points
somewhere else, Yazi does not read `~/.config/yazi`, and the script warns about
it.

## What's inside

```
yazi/
├── theme.toml    # the flavor and the transparent surfaces
└── package.toml  # packages ya pkg installs, always at their latest version
```

The package files themselves are not part of the repository: `install.sh`
downloads them into `~/.config/yazi`, and `.gitignore` keeps `yazi/flavors/` and
`yazi/plugins/` out in case a package is installed into the checkout.

- **Flavor.** `catppuccin-mocha` from
  [yazi-rs/flavors](https://github.com/yazi-rs/flavors), used in both the dark
  and the light terminal mode.
- **Transparency.** The flavor paints no background of its own; `theme.toml`
  still sets the window, the status bar and the which-key mask to the terminal
  background (`bg = "reset"`), so a later version of the flavor cannot bring one
  back there. Only the colored status-bar segments keep a background: the blue
  mode block and the gray `#313244` segments next to it.
- **Code preview** is highlighted with the flavor's `tmtheme.xml`, also without
  a background.

## Adding a package

Add an entry to `yazi/package.toml` — `[[plugin.deps]]` for a plugin,
`[[flavor.deps]]` for a flavor — with its `use` only, then run `./install.sh`:

```toml
[[plugin.deps]]
use = "yazi-rs/plugins:git"
```

`ya pkg` writes the installed revision and hash into the copy in
`~/.config/yazi`; the repository keeps no pinned versions.

## Known limitations

- **Every install depends on the latest package versions.** A breaking change
  upstream arrives with the next `./install.sh`; the previous config, packages
  included, stays in `~/.config/yazi.backup.<timestamp>`.
- **The flavor needs a terminal that reports its color scheme.** Yazi applies
  `flavor.toml` once the terminal answers its dark / light query; a terminal (or
  a multiplexer without passthrough) that never answers shows Yazi's default
  colors, with only the code preview in Catppuccin.
