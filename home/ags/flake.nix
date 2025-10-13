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
      nixpkgs,
      ags,
      astal,
      ...
    }:
    let
      pname = "ags-bundled";
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      nativeBuildInputs = [
        pkgs.wrapGAppsHook3
        pkgs.gobject-introspection
        ags.packages.${system}.default
      ];
      buildInputs = [
        pkgs.glib
        pkgs.gjs
        astal.packages.${system}.io
        astal.packages.${system}.astal3
        astal.packages.${system}.battery
        astal.packages.${system}.hyprland
        astal.packages.${system}.tray
        astal.packages.${system}.wireplumber
        astal.packages.${system}.apps
      ];

      extraDev = [
        pkgs.nodejs
        pkgs.dart-sass
      ];

      girDirs = pkgs.symlinkJoin {
        name = "gir-dirs";
        paths = map (
          pkg:
          if (pkgs.lib.filesystem.pathIsDirectory "${pkg.dev}/share/gir-1.0") then
            "${pkg.dev}/share/gir-1.0"
          else
            null
        ) buildInputs;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = buildInputs ++ extraDev;
        inherit nativeBuildInputs;

        shellHook = ''
          rm -rd ./@girs
          rm -rd ./node_modules
          ags types -d .
          mkdir node_modules
          ln -s ${ags.packages.${system}.ags.jsPackage} ./node_modules/ags
        '';
        GIO_EXTRA_MODULES = "${pkgs.glib-networking}/lib/gio/modules";
        EXTRA_GIR_DIRS = "${girDirs}";
      };

      packages.${system}.default = pkgs.stdenv.mkDerivation {
        name = pname;
        src = ./.;
        inherit nativeBuildInputs;
        inherit buildInputs;

        installPhase = ''
          runHook preInstall
          mkdir -p $out/bin
          mkdir -p $out/share
          cp -r * $out/share
          ags bundle app.tsx $out/bin/${pname} -d "SRC='$out/share'"
          runHook postInstall
        '';
      };
    };
}
