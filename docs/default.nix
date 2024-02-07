{ pkgs, ... }:

let
  makeOptionsDoc = configuration: pkgs.nixosOptionsDoc {
    inherit (configuration) options;
    transformOptions = option: option // {
      name = "fourmolu." + option.name;
    };
  };

  fourmolu = makeOptionsDoc
    (pkgs.lib.evalModules
      {
        modules = [
          ../modules
          { options._module.args = pkgs.lib.mkOption { internal = true; }; }
        ];
        specialArgs = { inherit pkgs; };
      });

in
pkgs.stdenvNoCC.mkDerivation {
  name = "fourmolu-nix-book";
  src = ./.;

  patchPhase = ''
    cp ${../README.md} src/README.md

    # The "declared by" links point to a file which only exists when the docs
    # are built locally. This removes the links.
    sed '/*Declared by:*/,/^$/d' <${fourmolu.optionsCommonMark} >>src/options.md
  '';

  buildPhase = ''
    ${pkgs.mdbook}/bin/mdbook build --dest-dir $out
  '';
}
