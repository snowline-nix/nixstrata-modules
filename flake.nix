{
  description = "nixstrata-modules";

  inputs.nixlib-general.url = "git+https://github.com/zudww/nixlib-general?ref=v0.3.0-a1";

  inputs.nixstrata-transforms.url = "github:snowline-nix/nixstrata-transforms";
  inputs.nixstrata-transforms.inputs.nixlib-general.follows = "nixlib-general";

  inputs.nixstrata-types.url = "github:snowline-nix/nixstrata-types";
  inputs.nixstrata-types.inputs.nixlib-general.follows = "nixlib-general";
  inputs.nixstrata-types.inputs.nixstrata-transforms.follows = "nixstrata-transforms";

  outputs = _: import ./src _;
}
