{
  description = "Home manager configuration - media";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    alejandra = {
      url = "github:kamadorueda/alejandra";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    beetsSrc = {
      url = "github:beetbox/beets";
      flake = false;
    };
    bizhawk = {
      url = "github:SignalWalker/BizHawk"; # TODO :: switch to TASEmulators/BizHawk if they merge my pull request
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    # harkinian = {
    #   url = "github:HarbourMasters/Shipwright";
    #   flake = false;
    # };
  };
  outputs =
    inputs@{
      self,
      nixpkgs,
      ...
    }:
    with builtins;
    let
      std = nixpkgs.lib;
    in
    {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      homeManagerModules.default =
        { lib, ... }:
        {
          options.signal.media.flakeInputs =
            with lib;
            mkOption {
              type = types.attrsOf types.anything;
              default = inputs;
            };
          imports = [
            ./home-manager.nix
          ];
          config = { };
        };
    };
}
