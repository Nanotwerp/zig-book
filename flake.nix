{
  description = "Zig development environment";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable-small";

    flake-utils.url = "github:numtide/flake-utils";

    zig-overlay = {
      url = "github:mitchellh/zig-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };

    zls = {
      url = "github:zigtools/zls";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
        zig-overlay.follows = "zig-overlay";
      };
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      zig-overlay,
      zls,
    }:
    let
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (system: f nixpkgs.legacyPackages.${system});
    in
    {
      devShell = forAllSystems (
        { pkgs, ... }:
        let
          zig = zig-overlay.outputs.packages.${pkgs.system}.master;
        in
        pkgs.mkShell {
          packages = [
            zig
            # (zls.packages.${system}.zls.overrideAttrs (oldAttrs: {
            #   nativeBuildInputs = [ zig ];
            #   buildPhase = oldAttrs.buildPhase;
            # }))
            zls.packages.${pkgs.system}.zls
            pkgs.lldb
          ];
        }
      );
    };
}
