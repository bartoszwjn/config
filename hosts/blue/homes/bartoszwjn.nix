{
  config,
  lib,
  pkgs,
  customPkgs,
  privateConfig,
  ...
}:
let
  systemPrivateConfig = privateConfig.hosts.blue;
  userPrivateConfig = systemPrivateConfig.bartoszwjn;
in
{
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
    dunst.enable = true;
    gpg.enable = true;
    gui-services.enableAll = true;
    home.enable = true;
    hyprland = {
      enable = true;
      monitors = {
        "desc:Dell Inc. DELL S2522HG".config = "1920x1080@240, 0x0, 1";
        "desc:GIGA-BYTE TECHNOLOGY CO. LTD. GS27QXA".config = "2560x1440@240, 0x0, 1";
        "".config = "preferred, auto-right, 1";
      };
      waybar.monitors = [
        "DP-1"
        "HDMI-A-1"
      ];
    };
    keyring.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    nix.enable = true;
    packages.cli = true;
    packages.gui = true;
    rofi.enable = true;
    shell.enable = true;
    ssh.enable = true;
    styling.enable = true;
    syncthing = {
      enable = true;
      inherit (userPrivateConfig.syncthing) certFile encryptedKeyFile;
      settings = {
        options.listenAddresses = [ "tcp://${systemPrivateConfig.tailscale.ipv4}:22000" ];
        folders.bartoszwjn-main.devices = [
          "arnold"
          "red"
        ];
      };
    };
    zathura.enable = true;
  };

  home = {
    username = "bartoszwjn";
    stateVersion = "24.11";
    packages = builtins.attrValues {
      inherit (customPkgs) chatterino2;
      inherit (pkgs) discord;
    };
  };

  xdg.dataFile."chatterino/Settings".source = config.lib.file.mkOutOfStoreSymlink (
    config.home.homeDirectory + "/syncthing/chatterino-settings"
  );
}
