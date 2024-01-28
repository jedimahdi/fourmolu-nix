{
  description = "fourmolu nix configuration modules";

  outputs = _: {
    lib = import ./lib;
    flakeModule = ./flake-module.nix;
  };
}
