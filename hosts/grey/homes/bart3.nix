{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  systemPrivateConfig = flakeInputs.private-config.lib.hosts.grey;
  userPrivateConfig = systemPrivateConfig.bart3;
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
      terraform = true;
      git = {
        enable = true;
        userEmail = {
          "~/repos/" = "bartoszwjn@gmail.com";
          "~/qed/" = "bart3@qed.ai";
        };
      };
    };
    dunst.enable = true;
    gpg.enable = true;
    gui-services.enableAll = true;
    home.enable = true;
    hyprland = {
      enable = true;
      monitors = {
        "eDP-1".config = "1920x1080@60, 0x0, 1";
        "eDP-1".isPrimary = true;
        "desc:Dell Inc. DELL S2522HG GQ6L1C3".config = "1920x1080@120, auto-left, 1";
        "desc:LG Electronics LG Ultra HD 0x00049402".config = "1920x1080@60, auto-left, 1";
        "".config = "preferred, auto-left, 1";
      };
      waybar.monitors = [
        "eDP-1"
        "DP-1"
        "HDMI-A-1"
      ];
      waybar.backlight.enable = true;
      waybar.battery.enable = true;
      waybar.battery.thresholds = {
        warning = 50;
        low = 25;
        critical = 15;
      };
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
      guiAddress = "127.0.0.1:8385";
      inherit (userPrivateConfig.syncthing) certFile encryptedKeyFile;
      settings = {
        options.listenAddresses = [ "tcp://${systemPrivateConfig.tailscale.ipv4}:22001" ];
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
    username = "bart3";
    stateVersion = "24.11";
    packages = builtins.attrValues {
      inherit (pkgs)
        awscli2
        git-review
        google-cloud-sdk
        postgresql
        slack
        ;
    };
  };
}
