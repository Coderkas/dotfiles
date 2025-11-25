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
      nil_git = inputs.nil.packages.${host_platform}.default;
    in
    {
      nvfim =
        (inputs.nvf.lib.neovimConfiguration {
          inherit pkgs;
          extraSpecialArgs = {
            inherit nil_git;
          };
          modules = [ ./nvf ];
        }).neovim;
      waydroid_script = import ./waydroid_script {
        inherit pkgs;
        inherit (inputs.nixpkgs) lib;
      };
    }
  );
}
