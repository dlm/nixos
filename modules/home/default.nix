{ lib, ... }:
let
  fileNames = builtins.attrNames (builtins.readDir ./.);
  nixFileNonDefault = (name: name != "default.nix" && lib.hasSuffix ".nix" name);
  nixFiles = builtins.filter nixFileNonDefault fileNames;
in
{
  imports = map (name: ./${name}) nixFiles;
}
