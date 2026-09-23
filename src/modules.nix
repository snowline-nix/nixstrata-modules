{ accForEachElem, attrNames, genAttrs, joinLists, listToAttrs, remapElems, typeOf, ... }:
{ resolveModule, types, ... }:
{
  resolveModule = inputs: inputModule: let
    moduleDef = let
      t = typeOf inputModule;
      t' = typeOf a;
      a = if t == "path" then (import inputModule) else inputModule;
    in
      if t' == "lambda" then a inputs
      else a;

    imports =
      if !(moduleDef ? imports) then []
      else remapElems moduleDef.imports (resolveModule inputs);

    module = {
      options = moduleDef.options or {};
      config = (moduleDef.config or {}) // (removeAttrs moduleDef [ "imports" "options" "config" ]);
    };
  in
     [ module ] ++ (joinLists imports);

  evalModules = {
    modules ? [],
    inputs ? {},
    class ? null,
  }@evalModuleInputs: let
    moduleDefs = joinLists (remapElems modules (resolveModule inputs));

    options = let
      merge = a: b: let
        updatedAttrs = listToAttrs (
          map
          (name: {
            name = name;
            value = let
              aAttr = a.${name};
              bAttr = b.${name};
            in
              if (bAttr._type or null) != "type"
                && (typeOf bAttr == "set")
                && a ? ${name}
                && (typeOf aAttr == "set")
              then merge aAttr bAttr
              else bAttr;
          })
          (attrNames b)
        );
      in
        a // updatedAttrs;
    in
      accForEachElem moduleDefs {} (acc: mod: merge acc mod.options);

    type = types.moduleOf options;

    eval = type.eval {
      context = { inherit type; path = []; };
      declarations = (remapElems moduleDefs (mod: mod.config));
    };
  in {
    _type = if evalModuleInputs ? class then "module.${class}" else "module";
    config = let
      conv = o:
        let decl = o.declarations; t = typeOf decl; in
        if t == "set" then genAttrs (attrNames decl) (name: conv decl.${name}) else
        if t == "list" then remapElems decl conv else
        decl;
    in
      conv eval;
  };
}
