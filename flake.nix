{
  description = "Home manager configuration - media";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    alejandra = {
      url = github:kamadorueda/alejandra;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homedesk = {
      url = github:signalwalker/nix.home.desktop;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    # games
    # modloader64 = {
    #   url = github:signalwalker/nix.games.modloader64;
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    ...
  }:
    with builtins; let
      homebase = inputs.homedesk.inputs.homebase;
      homelib = homebase.inputs.homelib;
      std = nixpkgs.lib;
      hlib = homelib.lib;
      nixpkgsFor = hlib.genNixpkgsFor {
        inherit nixpkgs;
        overlays = [ inputs.mozilla.overlays.rust ] ++ (hlib.collectInputOverlays (attrValues (removeAttrs inputs [ "self" ])));
      };
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      homeManagerModules.default = {lib, ...}: {
        options.signal.media.flakeInputs = with lib;
          mkOption {
            type = types.attrsOf types.anything;
            default = inputs;
          };
        imports =
          [
            ./home-manager.nix
          ]
          ++ (hlib.collectInputModules (attrValues (removeAttrs inputs ["self"])));
        config = {};
      };
      homeConfigurations =
        mapAttrs (system: pkgs: {
          default = hlib.genHomeConfiguration {
            inherit pkgs;
            modules = [self.homeManagerModules.default];
          };
        })
        nixpkgsFor;
      packages = hlib.genHomeActivationPackages self.homeConfigurations;
      apps = hlib.genHomeActivationApps self.homeConfigurations;
    };
}
