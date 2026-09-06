{
  description = "Pinned Hyprland and Quickshell desktop closure for Ubuntu";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";

    quickshell = {
      url = "github:quickshell-mirror/quickshell?ref=v0.2.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixgl = {
      url = "github:nix-community/nixGL";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, systems, quickshell, nixgl, ... }:
    let
      eachSystem = nixpkgs.lib.genAttrs (import systems);
    in {
      packages = eachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          mesaNixGL = nixgl.packages.${system}.nixGLIntel;
          nixGL = pkgs.writeShellScriptBin "nixGL" ''
            exec ${mesaNixGL}/bin/nixGLIntel "$@"
          '';
          desktop = pkgs.buildEnv {
            name = "dotfiles-linux-desktop";
            paths = [
              pkgs.hyprland
              pkgs.xdg-desktop-portal-hyprland
              quickshell.packages.${system}.default
              mesaNixGL
              nixGL
            ];
          };
        in {
          inherit desktop;
          default = desktop;
        });

      checks = eachSystem (system: {
        desktop = self.packages.${system}.desktop;
      });
    };
}
