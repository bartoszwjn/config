{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  privateConfig = flakeInputs.private-config.lib.grey.bart3;
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
        userEmail = {
          "~/repos/" = "bartoszwjn@gmail.com";
          "~/qed/" = "bart3@qed.ai";
        };
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
      guiAddress = "127.0.0.1:8385";
      inherit (privateConfig.syncthing) certFile encryptedKeyFile;
    };
    xmonad = {
      enable = true;
      xmobar.showBattery = true;
      stalonetray.geometry = "8x1+1728+0";
    };
    zathura.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bart3";
    stateVersion = "22.05";
    file = {
      ".screen-brightness".source =
        config.custom.base.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = privateConfig.sshConfig;
      ".Xresources".text = "Xft.dpi: 96\n";
    };
    packages = builtins.attrValues {
      inherit (pkgs) awscli2 git-review google-cloud-sdk postgresql slack;
    };
  };
}
