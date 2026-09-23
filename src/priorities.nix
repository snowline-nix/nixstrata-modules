let
  mkPriority = priority: value: {
    _type = "valueObject";
    inherit priority value;
  };

  mkOptionDefault = mkPriority 1500;

  mkDefault = mkPriority 1000;
in
{
  inherit mkPriority mkOptionDefault mkDefault;
}
