{
  config,
  lib,
  pkgs,
  ...
}:
{
  custom = {
    dev-tools = {
      enableAll = true;
      terraform.enable = false;
      vcs.userEmail = "bartoszwjn@gmail.com";
    };
    documentation.enable = true;
    home.enable = true;
    neovim.enable = true;
    nix.enable = true;
    packages = {
      cli.core.enable = true;
    };
    shell.enable = true;
  };

  home = {
    username = "bartoszwjn";
    stateVersion = "25.11";
  };
}
