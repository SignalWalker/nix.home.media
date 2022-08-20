{
  config,
  pkgs,
  lib,
  ...
}:
with builtins; let
  std = pkgs.lib;
in {
  options = with lib; {};
  imports = lib.signal.fs.listFiles ./programs;
  config = {
    services.kdeconnect.enable = true;
  };
}
