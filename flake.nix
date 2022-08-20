{
  description = "Home manager configuration - media";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixpkgs-unstable;
    alejandra = {
      url = github:kamadorueda/alejandra;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homelib = {
      url = github:signalwalker/nix.home.lib;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
    };
    homebase = {
      url = github:signalwalker/nix.home.base;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
    };
    homedesk = {
      url = github:signalwalker/nix.home.desktop;
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.alejandra.follows = "alejandra";
      inputs.homelib.follows = "homelib";
      inputs.homebase.follows = "homebase";
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
      homebase = inputs.homebase;
      homelib = inputs.homelib;
      std = nixpkgs.lib;
      hlib = homelib.lib;
      nixpkgsFor = hlib.genNixpkgsFor {
        inherit nixpkgs;
        overlays = system: (inputs.homedesk.lib.selectOverlays ["default" system "firefox"]) ++ (homebase.lib.selectOverlays ["default" system]) ++ (self.lib.selectOverlays ["default" system]);
      };
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      lib.overlays = hlib.aggregateOverlays (attrValues (removeAttrs inputs ["nixpkgs" "alejandra"]));
      lib.selectOverlays = hlib.selectOverlays' self;
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
          ++ (hlib.collectInputModules (attrValues (removeAttrs inputs ["self" "homebase" "homelib"])));
        config = {};
      };
      homeConfigurations =
        mapAttrs (system: pkgs: {
          default = hlib.genHomeConfiguration {
            inherit pkgs;
            modules = [
              self.homeManagerModules.default
              ({pkgs, ...}: {
                config.programs.firefox.package = pkgs.latest.firefox-nightly-bin;
              })
            ];
          };
        })
        nixpkgsFor;
      packages = hlib.genHomeActivationPackages self.homeConfigurations;
      apps = hlib.genHomeActivationApps self.homeConfigurations;
    };
}
