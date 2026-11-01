# Dave's Nix Config

Welcome to my nix configuration.  I have no idea how you ended up here but you
did.  Hit me up if you want to chat!  Enjoy the repo.

This repo is my workstations (`petrillo` and `zbornak`). The servers live in
[homelab](https://github.com/dlm/homelab), and app config (nvim, kitty, niri,
...) lives as plain dotfiles in [env](https://github.com/dlm/env), which this
repo links into place.

## Layout

- `hosts/` — one directory per machine, plus `common/` for what they share
  (`configuration.nix` for the system, `home.nix` for Home Manager).
- `modules/home/` — Home Manager modules, one per app or tool, each behind a
  `home.<name>.enable` option. Every file here is imported automatically.
- `modules/stacks/` — bigger system-level bundles (`desktop` for i3,
  `desktop-niri`, `backup`), each behind `stacks.<name>.enable`.
- `modules/system/` — smaller system modules.
- `packages/` — local flakes for software I package myself (`haplab`,
  `wavebox`).

Rebuild with:

```bash
sudo nixos-rebuild switch --flake .#<host>
```

# Notes

## Building against a local checkout of my own projects

Projects like `bivouac` and `muxwm` are pinned to GitHub in `flake.lock`. To
try local, uncommitted changes without pushing or touching the lock file,
override the input for a single rebuild:

```bash
sudo nixos-rebuild switch --flake .#petrillo \
    --override-input bivouac path:/home/dave/repos/dlm/bivouac
```

Once the changes are pushed, pick them up for real with
`nix flake update bivouac`.
