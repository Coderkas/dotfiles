{
  programs = {
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      enableBrowserSocket = true;
    };

    nano.enable = false;

    nh = {
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep 2";
      };
      flake = "/home/lorkas/dotfiles";
    };

    fish.enable = true;
  };
}
