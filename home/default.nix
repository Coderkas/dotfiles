{
  inputs,
  host_name,
  system,
  hypr-pkgs,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
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
