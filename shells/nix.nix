{self, ...}: system:
with self.pkgs.${system};
  mkShell {
    name = "nix-dev";
    buildInputs = [
      alejandra
      deadnix
      git
      nil
      pre-commit
      reuse
      statix
    ];
    shellHook = ''
      ${self.checks.${system}.pre-commit-check.shellHook}
    '';
  }
