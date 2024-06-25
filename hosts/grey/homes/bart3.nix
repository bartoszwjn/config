{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  systemPrivateConfig = flakeInputs.private-config.lib.hosts.grey;
  userPrivateConfig = systemPrivateConfig.bart3;
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
      monitorsConfig = [
        "eDP-1, 1920x1080@60, 0x0, 1"
        "desc:Dell Inc. DELL S2522HG GQ6L1C3, 1920x1080@120, auto-left, 1"
        "desc:LG Electronics LG Ultra HD 0x00049402, 1920x1080@60, auto-left, 1"
        ", preferred, auto-left, 1"
      ];
      waybar.monitors = ["eDP-1" "DP-1" "HDMI-A-1"];
      waybar.showBacklight = true;
      waybar.showBattery = true;
    };
    keyring.enable = true;
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
        options.listenAddresses = ["tcp://${systemPrivateConfig.tailscale.ipv4}:22001"];
        folders.bartoszwjn-main.devices = ["arnold" "red"];
      };
    };
    zathura.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bart3";
    stateVersion = "24.05";
    packages = builtins.attrValues {
      inherit (pkgs) awscli2 git-review google-cloud-sdk postgresql slack;
    };
  };
}
