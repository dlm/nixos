{ lib, ... }:
{
  options.home.envRepoPath = lib.mkOption {
    type = lib.types.str;
    default = "/home/dave/repos/dlm/env";
    description = ''
      Absolute path to the hand-edited dotfiles repo. Per-app home modules
      symlink their config out of here via mkOutOfStoreSymlink.

      Typed as a plain string, not lib.types.path: it's only ever used as a
      string prefix for building symlink targets, never coerced into an
      actual Nix path. Interpolating a real path value (rather than a
      string) into "''${...}" copies it into the Nix store, which requires
      reading it off disk -- forbidden for paths outside the flake under
      pure evaluation.
    '';
  };
}
