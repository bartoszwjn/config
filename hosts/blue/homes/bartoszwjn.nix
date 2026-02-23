{
  config,
  lib,
  pkgs,
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
      enableAll = true;
      terraform.enable = false;
      vcs.userEmail = "bartoszwjn@gmail.com";
    };
    documentation.enable = true;
    # dunst.enable = true;
    gpg.enable = true;
    gui-services.enableAll = true;
    home.enable = true;
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
    stateVersion = "25.05";
    packages = lib.attrValues {
      inherit (pkgs) discord;
    };
  };
}
