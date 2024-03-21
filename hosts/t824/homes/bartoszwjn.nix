{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: let
  systemPrivateConfig = flakeInputs.private-config.lib.t824;
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
    dunst.enable = true;
    gpg.enable = true;
    gui-services.enableAll = true;
    home.enable = true;
    hyprland = {
      enable = true;
      monitorsConfig = [
        # TODO eDP-1?
        "desc:Dell Inc. DELL S2522HG GQ6L1C3, 1920x1080@120, -1920x0, 1"
        ", preferred, auto, 1"
      ];
      waybar.monitors = ["eDP-1" "HDMI-A-1"]; # TODO
      waybar.showBattery = true;
    };
    neovim.enable = true;
    nix.enable = true;
    nushell.enable = true;
    packages.cli = true;
    packages.gui = true;
    rofi.enable = true;
    styling.enable = true;
    syncthing = {
      enable = true;
      inherit (userPrivateConfig.syncthing) certFile encryptedKeyFile;
      settings = {
        options.listenAddresses = ["tcp://${systemPrivateConfig.tailscale.ipv4}:22000"];
        folders.bartoszwjn-main.devices = ["arnold" "red"];
      };
    };
    zathura.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bartoszwjn";
    stateVersion = "23.11";
    file = {
      ".screen-brightness".source =
        config.custom.repo.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = userPrivateConfig.sshConfig;
    };
    packages = builtins.attrValues {
      inherit (pkgs) chatterino2 discord;
    };
  };
}
