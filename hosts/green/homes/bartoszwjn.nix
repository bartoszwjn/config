{
  config,
  lib,
  pkgs,
  customPkgs,
  privateConfig,
  ...
}:
let
  systemPrivateConfig = privateConfig.hosts.green;
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
        "eDP-1".config = "2880x1920@120, 0x0, 2";
        "eDP-1".isPrimary = true;
        "desc:Dell Inc. DELL S2522HG".config = "1920x1080@240, auto-left, 1";
        "desc:GIGA-BYTE TECHNOLOGY CO. LTD. GS27QXA".config = "2560x1440@144, -560x-1440, 1";
        "desc:LG Electronics LG IPS QHD".config = "2560x1440@100, -560x-1440, 1";
        "".config = "preferred, auto-left, 1";
      };
      waybar.monitors = [
        "eDP-1"
        # Expansion card slots
        "DP-2" # back right (slot 3)
        "DP-3" # back left (slot 1)
        "DP-4" # front right (slot 4)
      ];
      waybar.backlight.enable = true;
      waybar.battery.enable = true;
      waybar.powerProfiles.enable = true;
    };
    keyring.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    nix.enable = true;
    nushell.enable = true;
    packages.cli = true;
    packages.gui = true;
    rofi.enable = true;
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
    zsh.enable = true;
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
