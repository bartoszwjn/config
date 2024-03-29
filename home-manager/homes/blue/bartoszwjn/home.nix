{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  systemPrivateConfig = flakeInputs.private-config.lib.blue;
  userPrivateConfig = systemPrivateConfig.bartoszwjn;
in {
  custom = {
    alacritty.enable = true;
    dev-tools = {
      general = true;
      jsonnet = true;
      lua = true;
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
    home.enable = true;
    neovim.enable = true;
    nix.enable = true;
    nushell.enable = true;
    packages.enable = true;
    rofi.enable = true;
    services.enableAll = true;
    styling.enable = true;
    syncthing = {
      enable = true;
      inherit (userPrivateConfig.syncthing) certFile encryptedKeyFile;
      settings = {
        options.listenAddresses = ["tcp://${systemPrivateConfig.tailscale.ipv4}:22000"];
        folders.bartoszwjn-main.devices = ["arnold" "red"];
      };
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
    stateVersion = "23.11";
    file = {
      ".ssh/config".source = userPrivateConfig.sshConfig;
    };
    packages = builtins.attrValues {
      inherit (pkgs) chatterino2 discord;
    };
  };
}
