{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.okular;
  inherit (config.machine) owner;
in
{
  options.machine.okular.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.machine.desktop.enable;
  };

  config = lib.mkIf cfg.enable {
    hjem.users.${owner}.xdg.config.files."okularpartrc".text = ''
      [Dlg Accessibility]
      RecolorBackground=40,40,40
      RecolorForeground=235,219,178

      [Document]
      ChangeColors=true
      RenderMode=Recolor

      [General]
      ShellOpenFileInTabs=true
      ShowSidebar=false

      [Main View]
      ShowLeftPanel=false

      [PageView]
      UseCustomBackgroundColor=true

      [UiSettings]
      ColorScheme=BreezeDark
    '';

    environment.systemPackages = [ pkgs.kdePackages.okular ];
  };
}
