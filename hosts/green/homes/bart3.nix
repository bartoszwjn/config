{
  config,
  lib,
  pkgs,
  privateConfig,
  ...
}:
let
  systemPrivateConfig = privateConfig.hosts.green;
  userPrivateConfig = systemPrivateConfig.bart3;
in
{
  custom = {
    alacritty.enable = true;
    dev-tools = {
      enableAll = true;
      vcs.userEmail = {
        "~/repos/" = "bartoszwjn@gmail.com";
        "~/qed/" = "bart3@qed.ai";
      };
    };
    documentation.enable = true;
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
  };

  home = {
    username = "bart3";
    stateVersion = "25.11";
    packages = lib.attrValues {
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
