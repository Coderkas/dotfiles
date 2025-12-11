{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.machine.terminals;
  inherit (config.machine) owner theme;
in
{
  options.machine.terminals.enableKitty = lib.mkEnableOption "";

  config = lib.mkIf cfg.enableKitty {
    hjem.users.${owner}.xdg.config.files."kitty/kitty.conf" = {
      generator = lib.generators.toKeyValue {
        listsAsDuplicateKeys = true;
        mkKeyValue = lib.generators.mkKeyValueDefault { } " ";
      };
      value = {
        font_family = theme.font;
        font_size = 14;
        window_margin_width = 10;
        tab_bar_style = "fade";
        tab_fade = 1;
        shell_integration = "no-rc";
        shell = "${lib.getExe pkgs.fish} -l -i";
        include = "${pkgs.kitty-themes}/share/kitty-themes/themes/${theme.kitty}.conf";
      };
    };

    programs = {
      bash.interactiveShellInit = lib.mkAfter ''
        if test -n "$KITTY_INSTALLATION_DIR"; then
          export KITTY_SHELL_INTEGRATION="no-rc"
          source "$KITTY_INSTALLATION_DIR/shell-integration/bash/kitty.bash"
        fi
      '';

      fish.interactiveShellInit = lib.mkAfter ''
        if set -q KITTY_INSTALLATION_DIR
          set --global KITTY_SHELL_INTEGRATION "no-rc"
          source "$KITTY_INSTALLATION_DIR/shell-integration/fish/vendor_conf.d/kitty-shell-integration.fish"
          set --prepend fish_complete_path "$KITTY_INSTALLATION_DIR/shell_integration/fish/vendor_completions.d"
        end
      '';
    };

    environment.systemPackages = [
      pkgs.kitty
    ];
  };
}
