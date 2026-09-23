{ nixlib-general, nixstrata-types, nixstrata-transforms, ... }:
let
  ng = nixlib-general.lib;
  nt1 = nixstrata-types.lib;
  nt2 = nixstrata-transforms.lib;

  lib = {
    modules = import ./modules.nix ng lib;
    options = import ./options.nix lib;
    priorities = import ./priorities.nix;
    types = import ./types.nix ng nt1 nt2;

    inherit (lib.modules)
      evalModules
      resolveModule
      ;

    inherit (lib.priorities)
      mkPriority
      mkOptionDefault
      mkDefault
      ;

    inherit (lib.options)
      mkOption
      ;
  };
in
{ inherit lib; types = nt1.types; }
