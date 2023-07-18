{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ../../common/home.nix
  ];

  custom = {
    base.enable = true;
    dev-tools = {
      general = true;
      nix = true;
      python = true;
      rust = true;
    };
    nushell.enable = true;
    rofi.enable = true;
    zsh.enable = true;
  };

  home = {
    username = "bart3";
    stateVersion = "22.05";
    file = {
      ".screen-brightness".source =
        config.custom.base.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = flakeInputs.private-config.lib.grey.bart3.sshConfig;
      ".Xresources".text = "Xft.dpi: 96\n";
    };
    packages = builtins.attrValues {
      inherit (pkgs) awscli2 google-cloud-sdk postgresql slack teams terraform;
    };
  };

  programs.git.includes = [
    {
      condition = "gitdir:~/repos/";
      contents.user.email = "bartoszwjn@gmail.com";
    }
    {
      condition = "gitdir:~/qed/";
      contents.user.email = "bart3@qed.ai";
    }
  ];

  xmobar = {
    showBattery = true;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1+1728+0";
}
