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
    in {
      formatter = std.mapAttrs (system: pkgs: pkgs.default) inputs.alejandra.packages;
      signalModules.default = {
        name = "home.media.default";
        dependencies = hlib.signal.dependency.default.fromInputs {
          inherit inputs;
          filter = ["homelib"];
        };
        outputs = dependencies: {
          homeManagerModules.default = {lib, ...}: {
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
      homeConfigurations = home.genConfigurations self;
      packages = home.genActivationPackages self.homeConfigurations;
      apps = home.genActivationApps self.homeConfigurations;
    };
}
