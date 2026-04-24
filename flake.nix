{
  description = "Nix Flake Collection for Zephyr SDK Toolchain";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pre-commit-hooks,
    ...
  } @ inputs:
    flake-utils.lib.eachSystem [
      "x86_64-linux"
      "aarch64-linux"
      "aarch64-darwin"
    ] (system: {
      pkgs = import nixpkgs {
        inherit system;
        config = {allowUnfree = true;};
      };

      packages = {
        zephyr-sdk = self.pkgs.${system}.callPackage ./packages/zephyr-sdk inputs;
        zephyr-sdk-gnu = self.packages.${system}.zephyr-sdk.override { toolchain_provider = "gnu"; };
        zephyr-sdk-llvm = self.packages.${system}.zephyr-sdk.override { toolchain_provider = "llvm"; };
        default = self.packages.${system}.zephyr-sdk;
      };

      devShells = {
        zephyr = import ./shells/zephyr.nix inputs system self.packages.${system}.zephyr-sdk;
        zephyr-gnu = import ./shells/zephyr.nix inputs system self.packages.${system}.zephyr-sdk-gnu;
        zephyr-llvm = import ./shells/zephyr.nix inputs system self.packages.${system}.zephyr-sdk-llvm;
        nix = import ./shells/nix.nix inputs system;
        default = self.devShells.${system}.nix;
      };

      checks = {
        pre-commit-check =
          pre-commit-hooks.lib.${system}.run
          {
            src = self.pkgs.${system}.lib.cleanSource ./.;
            hooks = {
              editorconfig-checker.enable = true;
              statix.enable = true;
              deadnix.enable = true;
              alejandra.enable = true;
            };
          };
      };
    });
}
