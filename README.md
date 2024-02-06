# Fourmolu-nix

`fourmolu-nix` makes a wrapper for fourmolu with settings already pass to it so
you no longer need `fourmolu.yaml` or even to be in root of project to have
these options set for you.

## Getting started

For creating the wrapper, you can use `mkWrapper` function from lib which takes
pkgs and configuration and returns wrapped fourmolu with the provided configuration.

### Flakes

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    utils.url = "github:numtide/flake-utils";
    fourmolu-nix.url = "github:jedimahdi/fourmolu-nix";
  };

  outputs = {
    nixpkgs,
    utils,
    fourmolu-nix,
    ...
  }:
    utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
        fourmoluWrapper = fourmolu-nix.lib.mkWrapper pkgs {
          settings = {
            indentation = 4;
            comma-style = "leading";
            record-brace-space = true;
            extensions = ["OverloadedRecordDot", "RecordWildCards"];
          };
        };
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            fourmoluWrapper
          ];
        };
      }
    );
}
```

### Flake-parts

With flake-parts you don't need to call `mkWrapper`, just add
`inputs.fourmolu-nix.flakeModule` to list of imports.

Fourmolu wrapper will be accessible via `config.fourmolu.wrapper`.

```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    fourmolu-nix.url = "github:jedimahdi/fourmolu-nix";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        inputs.fourmolu-nix.flakeModule
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin"];
      perSystem = {
        config,
        pkgs,
        ...
      }: {
        fourmolu.settings = {
          indentation = 4;
          import-export-style = "diff-friendly";
          extensions = ["ImportQualifiedPost" "OverloadedRecordDot"];
        };

        devShells.default = pkgs.mkShell {
          nativeBuildInputs = [
            config.fourmolu.wrapper
          ];
        };
      };
    };
}
```

Note: `fourmolu-nix` will automatically set the wrapper package for `treefmt-nix`
fourmolu program.
