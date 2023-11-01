{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  privateConfig = flakeInputs.private-config.lib.blue.bartoszwjn;
in {
  custom = {
    alacritty.enable = true;
    base.enable = true;
    dev-tools = {
      general = true;
      nix = true;
      python = true;
      rust = true;
      git = {
        enable = true;
        userEmail = "bartoszwjn@gmail.com";
      };
    };
    doom-emacs.enable = true;
    gpg.enable = true;
    nushell.enable = true;
    packages.enable = true;
    rofi.enable = true;
    services.enableAll = true;
    styling.enable = true;
    syncthing = {
      enable = true;
      inherit (privateConfig.syncthing) certFile encryptedKeyFile;
    };
    xmonad = {
      enable = true;
      xmobar.showBattery = false;
      stalonetray.geometry = "8x1-0+0";
    };
    zathura.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bartoszwjn";
    stateVersion = "22.05";
    file = {
      ".ssh/config".source = privateConfig.sshConfig;
    };
    packages = builtins.attrValues {
      inherit (pkgs) chatterino2 discord;
    };
  };
}
