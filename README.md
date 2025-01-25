# Dave's Nix Config

Welcome to my nix configuration.  I have no idea how you ended up here but you
did.  Hit me up if you want to chat!  Enjoy the repo.

# Notes 

This section contains some notes on items that I am currently working on and
workarounds that I have yet to fix.

## Networking on Petrillo

When using nix and i3 on `petrillo`, the network manager fails when I login.
To work around this, run:

    sudo systemctl restart NetworkManager.service
