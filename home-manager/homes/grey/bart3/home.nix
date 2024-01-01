{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  systemPrivateConfig = flakeInputs.private-config.lib.grey;
  userPrivateConfig = systemPrivateConfig.bart3;
in {
  custom = {
    alacritty.enable = true;
    base.enable = true;
    dev-tools = {
      general = true;
      jsonnet = true;
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
    neovim.enable = true;
    nushell.enable = true;
    packages.enable = true;
    rofi.enable = true;
    services.enableAll = true;
    styling.enable = true;
    syncthing = {
      enable = true;
      guiAddress = "127.0.0.1:8385";
      inherit (userPrivateConfig.syncthing) certFile encryptedKeyFile;
      settings = {
        options.listenAddresses = ["tcp://${systemPrivateConfig.tailscale.ipv4}:22001"];
        folders.bartoszwjn-main.devices = ["arnold" "red"];
      };
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
    stateVersion = "23.11";
    file = {
      ".screen-brightness".source =
        config.custom.base.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = userPrivateConfig.sshConfig;
      ".Xresources".text = "Xft.dpi: 96\n";
    };
    packages = builtins.attrValues {
      inherit (pkgs) awscli2 git-review google-cloud-sdk postgresql slack;
    };
  };
}
