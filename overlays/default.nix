{
  pkgs,
  ...
}:
{
  nixpkgs.overlays = [
    (final: prev: {
      # use own patch for manix to fix home-manager stuff
      manix = prev.manix.overrideAttrs (oldAttrs: {
        version = "0.8.0";
        src = final.fetchFromGitHub {
          owner = "nix-community";
          repo = "manix";
          rev = "v${"0.8.0"}";
          hash = "sha256-b/3NvY+puffiQFCQuhRMe81x2wm3vR01MR3iwe/gJkw=";
        };
        useFetchCargoVendor = true;
        cargoHash = "sha256-6KkZg8MXQIewhwdLE8NiqllJifa0uvebU1/MqeE/bdI=";

        patches = (oldAttrs.patches or [ ]) ++ [ ./manix.patch ];
      });
      # Bleeding edge lutris 10.06.2025
      lutris-unwrapped = prev.lutris-unwrapped.overrideAttrs {
        src = final.fetchFromGitHub {
          owner = "lutris";
          repo = "lutris";
          rev = "96779137fe8ac684c89f4090e60fb8f9f8839d38";
          hash = "sha256-UoSj/72i4BHg43tmXr7UTQIXY0o6pVnmezc7wBpEAYQ=";
        };
      };
      # Get additional properties for media files (see nautilus entry in nixos wiki)
      nautilus = prev.nautilus.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [
          pkgs.gst_all_1.gst-plugins-good
          pkgs.gst_all_1.gst-plugins-bad
        ];
      });
    })
  ];
}
