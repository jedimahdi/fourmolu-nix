let
  evalModule = pkgs: configuration:
    pkgs.lib.evalModules {
      modules = [../modules configuration];
      specialArgs = {inherit pkgs;};
    };
  mkWrapper = pkgs: configuration: let
    mod = evalModule pkgs configuration;
  in
    mod.config.wrapper;
in {
  inherit evalModule mkWrapper;
}
