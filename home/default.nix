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
      inherit inputs;
      inherit host_name;
      inherit system;
      inherit hypr-pkgs;
    };
    users.lorkas = import ./home.nix;
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
    enableLegacyProfileManagement = false;
  };
}
