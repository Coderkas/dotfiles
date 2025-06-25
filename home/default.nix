{
  inputs,
  host_name,
  system,
  ...
}:
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];
  home-manager = {
    extraSpecialArgs = {
      inherit inputs host_name system;
    };
    users.lorkas = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    sharedModules = [ inputs.ags.homeManagerModules.default ];
  };
}
