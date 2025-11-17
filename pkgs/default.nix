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
      ags-git = inputs.ags.packages.${host_platform};
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
      ags-bundled =
        (import ./ags {
          inherit ags-git pkgs;
        }).package;
    }
  );

  dvShells = eachSystem (
    host_platform:
    let
      pkgs = inputs.nixpkgs.legacyPackages.${host_platform};
      ags-git = inputs.ags.packages.${host_platform};
    in
    {
      ags-shell =
        (import ./ags {
          inherit ags-git pkgs;
        }).shell;
    }
  );
}
