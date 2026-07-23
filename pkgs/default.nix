{ inputs, ... }:
let
  systems = [
    "x86_64-linux"
    "aarch64-linux"
  ];
  eachSystem = inputs.nixpkgs.lib.genAttrs systems;
in
{
  packages = eachSystem (
    host_platform:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${host_platform};
    in
    {
      waydroid_script = import ./waydroid_script.nix {
        inherit pkgs;
        inherit (inputs.nixpkgs) lib;
      };
    }
  );
}
