{ lib, flake-parts-lib, ... }:
let
  inherit (lib) mkOption types;
in
{
  options = {
    perSystem = flake-parts-lib.mkPerSystemOption ({ config, options, pkgs, ... }: {
      options = {
        fourmolu = mkOption {
          description = ''
            Project-level fourmolu configuration

            Use `config.fourmolu.wrapper` to get access to the resulting fourmolu
            package based on this configuration.
          '';
          type = types.submoduleWith {
            specialArgs = { inherit pkgs; };
            modules = [ ./modules ];
          };
          default = { };
        };
      };
    });
  };
}
