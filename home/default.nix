{
  inputs,
  host_name,
  system,
  hypr-pkgs,
  nvfim,
  ...
}:
{
  home-manager = {
    extraSpecialArgs = {
      inherit
        inputs
        host_name
        system
        hypr-pkgs
        nvfim
        ;
    };
    users.lorkas = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    sharedModules = [ inputs.ags.homeManagerModules.default ];
  };
}
