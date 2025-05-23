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
  disabledModules = [];
  imports = [];
  config = {
    home.packages = with pkgs; [rssguard];
    desktop.scratchpads = {
      "Shift+R" = {
        criteria = {
          app_id = "io.github.martinrotter.rssguard";
          # title = "^(\\[[0-9]*\\] )?RSS Guard [0-9]\\.[0-9]\\.[0-9]";
        };
        hypr = {
        };
        name = "rssguard";
        resize = 93;
        startup = "rssguard";
        systemdCat = true;
        automove = true;
        autostart = true;
      };
    };
  };
  meta = {};
}
