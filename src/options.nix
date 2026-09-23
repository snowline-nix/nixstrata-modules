{ mkOptionDefault, ... }:
{
  mkOption = {
    description ? null,

    type,
    default ? null,
  }@option:
    type // {
      eval = { context, declarations, ... }@inputs:
        type.eval (inputs // {
          context = context // { inherit option; };
          declarations =
            if default == null then declarations
            else declarations ++ [ (mkOptionDefault default) ];
        });
    };
}
