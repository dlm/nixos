# Notes 

When using nix and i3 on `petrillo`, the network manager fails when I login.
To work around this, run:

    sudo systemctl restart NetworkManager.service
