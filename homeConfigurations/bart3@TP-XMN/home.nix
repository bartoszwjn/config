{
  config,
  lib,
  pkgs,
  flakeInputs,
  ...
}: {
  imports = [
    ../common/home.nix
  ];

  isNixos = false;

  # Workaround for https://github.com/nix-community/home-manager/issues/2942
  nixpkgs.config.allowUnfreePredicate = pkg: true;

  home = {
    username = "bart3";
    packages = builtins.attrValues {
      inherit (pkgs) awscli2 google-cloud-sdk slack teams terraform;
    };
    file = {
      ".screen-brightness".source = config.flakeRoot + "/scripts/laptop/screen-brightness";
      ".ssh/config".source = flakeInputs.private-config.lib.TP-XMN.bart3.sshConfig;
      ".Xresources".text = "Xft.dpi: 96";
    };
  };

  programs.git.userEmail = "bart3@qed.ai";

  xmobar = {
    showBattery = true;
    ultrawideDisplay = false;
  };

  services.stalonetray.geometry = "8x1+1728+0";

  systemd.user.services.network-manager-applet = {
    Unit = {
      Description = "Applet for managing network connections";
      After = ["graphical-session-pre.target"];
      PartOf = ["graphical-session.target"];
    };
    Install.WantedBy = ["graphical-session.target"];
    Service.ExecStart = "/usr/bin/nm-applet";
  };
}
