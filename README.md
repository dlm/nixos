# Dave's Nix Config

Welcome to my nix configuration.  I have no idea how you ended up here but you
did.  Hit me up if you want to chat!  Enjoy the repo.

# Notes

This section contains some notes on items that I am currently working on and
workarounds that I have yet to fix.

## Integrating nixos repo into vcs.py

I have the following constraints:
- I like to manage my repositories though vcs.py
- I like to have my nixos configs in version control
- I like to have my nixos configs in the root
- I seem to run into problems when I symlink my nixos configs

So, as a work around, I have the nixos repoin the home directory and not part of
vcs.py.

## Networking on Petrillo

When using nix and i3 on `petrillo`, the network manager fails when I login.
To work around this, run:

    sudo systemctl restart NetworkManager.service

## Complex "default" tools (like nvim)

I like having nvim available to me, unfortunately having a comfy nvim setup
where nvim is installed "globally" (either at the system or user level) really
does a number on the environment.  Obviously, I can switch my config fully over
to something that is very nix based (like nixvim) however I would prefer to
avoid an abstraction of an abstraction.  So I would like to try the following.
For a program that pulls in a lot of system dependencies, create a flake to
define that program in the way I like, and then start that program in its own
environment  for example

```bash
alias v="nix develop <path-to-nvim-flake> --command nvim"
```
