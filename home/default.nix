{
  inputs,
  host_name,
  system,
  hypr-pkgs,
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
        ;
    };
    users.lorkas = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    sharedModules = [ inputs.ags.homeManagerModules.default ];
  };
}
