{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit
    (lib)
    mkOption
    types
    ;
  settingsSubmodule = types.submodule {
    options = {
      indentation = mkOption {
        type = types.ints.positive;
        default = 2;
        example = 4;
        description = ''
          Number of spaces per indentation step
        '';
      };
      column-limit = mkOption {
        type = types.either (types.enum ["none"]) types.ints.positive;
        default = "none";
        example = 80;
        description = ''
          Max line length for automatic line breaking
        '';
      };
      function-arrows = mkOption {
        type = types.enum ["trailing" "leading" "leading-args"];
        default = "trailing";
        example = "leading";
        description = ''
          Styling of arrows in type signatures
        '';
      };
      comma-style = mkOption {
        type = types.enum ["trailing" "leading"];
        default = "leading";
        description = ''
          How to place commas in multi-line lists, records, etc.
        '';
      };
      import-export-style = mkOption {
        type = types.enum ["trailing" "leading" "diff-friendly"];
        default = "diff-friendly";
        example = "leading";
        description = ''
          Styling of import/export lists
        '';
      };
      indent-wheres = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to full-indent or half-indent 'where' bindings past the preceding body
        '';
      };
      record-brace-space = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Whether to leave a space before an opening record brace
        '';
      };
      newlines-between-decls = mkOption {
        type = types.ints.positive;
        default = 1;
        description = ''
          Number of spaces between top-level declarations
        '';
      };
      haddock-style = mkOption {
        type = types.enum ["single-line" "multi-line" "multi-line-compact"];
        default = "multi-line";
        description = ''
          How to print Haddock comments
        '';
      };
      haddock-style-module = mkOption {
        type = types.enum ["single-line" "multi-line" "multi-line-compact"];
        default = "multi-line";
        description = ''
          How to print module docstring
        '';
      };
      let-style = mkOption {
        type = types.enum ["auto" "inline" "newline" "mixed"];
        default = "auto";
        description = ''
          Styling of let blocks
        '';
      };
      in-style = mkOption {
        type = types.enum ["right-align" "left-align" "no-space"];
        default = "right-align";
        description = ''
          How to align the 'in' keyword with respect to the 'let' keyword
        '';
      };
      single-constraint-parens = mkOption {
        type = types.enum ["auto" "always" "never"];
        default = "always";
        description = ''
          Whether to put parentheses around a single constraint
        '';
      };
      unicode = mkOption {
        type = types.enum ["detect" "always" "never"];
        default = "never";
        description = ''
          Output Unicode syntax
        '';
      };
      respectful = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Give the programmer more choice on where to insert blank lines
        '';
      };
      extensions = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          List of ghc extensions to pass to fourmolu
        '';
      };
      options = mkOption {
        type = types.listOf types.str;
        default = [];
        description = ''
          Fourmolu options to pass to wrapped fourmolu
        '';
      };
    };
  };
in {
  options = {
    package = mkOption {
      type = types.package;
      default = pkgs.haskellPackages.fourmolu;
      defaultText = lib.literalExpression "pkgs.haskellPackages.fourmolu";
      description = ''
        fourmolu derivation to use.
      '';
    };
    settings = mkOption {
      type = settingsSubmodule;
      description = ''
        fourmolu configuration
      '';
      default = {};
    };
    wrapper = mkOption {
      description = ''
        The fourmolu package, wrapped with the settings as arguments.
      '';
      type = types.package;
      defaultText = lib.literalMD "wrapped `fourmolu` command";
      readOnly = true;
    };
  };

  config = {
    settings.options =
      [
        "--indentation"
        (builtins.toString config.settings.indentation)
        "--column-limit"
        (builtins.toString config.settings.column-limit)
        "--function-arrows"
        config.settings.function-arrows
        "--comma-style"
        config.settings.comma-style
        "--import-export-style"
        config.settings.import-export-style
        "--indent-wheres"
        (lib.boolToString config.settings.indent-wheres)
        "--record-brace-space"
        (lib.boolToString config.settings.record-brace-space)
        "--newlines-between-decls"
        (builtins.toString config.settings.newlines-between-decls)
        "--haddock-style"
        config.settings.haddock-style
        "--haddock-style-module"
        config.settings.haddock-style-module
        "--let-style"
        config.settings.let-style
        "--in-style"
        config.settings.in-style
        "--single-constraint-parens"
        config.settings.single-constraint-parens
        "--unicode"
        config.settings.unicode
        "--respectful"
        (lib.boolToString config.settings.respectful)
      ]
      ++ builtins.concatMap (e: ["--ghc-opt" "-X${e}"]) config.settings.extensions;
    wrapper = pkgs.writeShellScriptBin "fourmolu" ''
      exec ${config.package}/bin/fourmolu ${builtins.concatStringsSep " " config.settings.options} "$@"
    '';
  };
}
