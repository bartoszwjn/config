{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}:
let
  systemPrivateConfig = flakeInputs.private-config.lib.hosts.green;
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
      monitorsConfig = [
        # TODO
        "desc:Dell Inc. DELL S2522HG GQ6L1C3, 1920x1080@120, auto-left, 1"
        "desc:LG Electronics LG Ultra HD 0x00049402, 1920x1080@60, auto-left, 1"
        ", preferred, auto-left, 1"
      ];
      waybar.monitors = [
        # TODO
        "eDP-1"
        "DP-1"
        "HDMI-A-1"
      ];
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
    zathura.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bartoszwjn";
    stateVersion = "24.05";
    packages = builtins.attrValues {
      inherit (flakeInputs.self.packages.${pkgs.hostPlatform.system}) chatterino2;
      inherit (pkgs) discord;
    };
  };
}
