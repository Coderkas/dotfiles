{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    astal = {
      url = "github:aylur/astal";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ags = {
      url = "github:aylur/ags";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.astal.follows = "astal";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      ags,
      astal,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      buildInputs = [
        pkgs.glib
        pkgs.gjs
        pkgs.wrapGAppsHook3
        pkgs.gobject-introspection
        astal.packages.${system}.io
        astal.packages.${system}.astal3
        astal.packages.${system}.battery
        astal.packages.${system}.hyprland
        astal.packages.${system}.tray
        astal.packages.${system}.wireplumber
        astal.packages.${system}.apps
      ];

      bins = [
        pkgs.gjs
        pkgs.nodejs
        pkgs.dart-sass
        astal.packages.${system}.io
      ];

      girDirs =
        let
          depsOf = pkg: [ (pkg.dev or pkg) ] ++ (map depsOf (pkg.propagatedBuildInputs or [ ]));
        in
        pkgs.symlinkJoin {
          name = "gir-dirs";
          paths = pkgs.lib.flatten (map depsOf buildInputs);
        };
    in
    {
      devShells.${system}.default =

        pkgs.mkShell {
          buildInputs = buildInputs;

          preFixup = ''
            gappsWrapperArgs+=(
            --prefix EXTRA_GIR_DIR : "${girDirs}/share/gir-1.0"
            --prefix PATH : "${pkgs.lib.makeBinPath (bins)}"
            )
          '';

          shellHook = ''
            ags types -d .
            mkdir node_modules
            ln -s ${ags.packages.${system}.gjsPackage}/share/ags/js ./node_modules/ags
          '';
          GIO_EXTRA_MODULES = "${pkgs.glib-networking}/lib/gio/modules";
        };
    };
}
