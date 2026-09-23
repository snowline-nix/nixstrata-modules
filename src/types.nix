{ allElems, attrNames, isAttrset, joinStringsSep, listToAttrs, remapElems, ... }:
{ mkType, ... }:
{ mkTypeTransformStep, transformers, errors, ... }:
{
  moduleOf = structDef:
    let structAttrNames = attrNames structDef; in
    mkType {
      name = "module";
      description = "attrset with predefined attribute names and value types";
      fullDefinitionName =
        "module with "
        + joinStringsSep ", " (
          remapElems structAttrNames
          (attr: "\"${attr}\" (${structDef.${attr}.fullDefinitionName})")
        );

      forceCheck = x:
        !(isAttrset x)
        && allElems (name: structDef ? ${name} && structDef.${name}.forceCheck x.${name}) structAttrNames;

      transforms.overrides.typeCheck = {
        identifier = "passthrough";
        operation = _: _;
      };

      transforms.overrides.mergeMethod = transformers.attrsAsDecls;

      transforms.mixins = let
        transform = mkTypeTransformStep {
          identifier = "compoundValueEvals.lazyStruct";
          operation = { declarations, context, ... }: listToAttrs (
            remapElems (attrNames declarations)
            (n: {
              name = n;
              value = let
                type =
                  if structDef ? ${n} then structDef.${n}
                  else errors.typeCheckErr { inherit context transform declarations; valueObj = { value = declarations; }; };
              in
                type.eval {
                  context = context // {
                    inherit type;
                    path = context.path ++ [ { type = "attribute"; address = n; } ];
                  };
                  declarations = declarations.${n};
                };
            })
          );
        };
      in [
        (t: t ++ [ transform ])
      ];
    };
}
