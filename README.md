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
