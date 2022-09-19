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
      std = nixpkgs.lib;
      hlib = inputs.homelib.lib;
      home = hlib.home;
      signal = hlib.signal;
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      signalModules.default = {
        name = "home.media.default";
        dependencies = signal.flake.set.toDependencies {
          flakes = inputs;
          filter = [];
        };
        outputs = dependencies: {
          homeManagerModules = {lib, ...}: {
            options.signal.media.flakeInputs = with lib;
              mkOption {
                type = types.attrsOf types.anything;
                default = dependencies;
              };
            imports = [
              ./home-manager.nix
            ];
            config = {};
          };
        };
      };
      homeConfigurations = home.configuration.fromFlake {
        flake = self;
        flakeName = "home.media";
      };
      packages = home.package.fromHomeConfigurations self.homeConfigurations;
      apps = home.app.fromHomeConfigurations self.homeConfigurations;
    };
}
