{
  config,
  lib,
  pkgs,
  ...
}: {
  environment.systemPackages = [pkgs.xterm];

  services.xserver = {
    enable = true;
    windowManager.xmonad.enable = true;
    displayManager.lightdm = {
      enable = true;
      background = config.custom.repo.flakeRoot + "/misc/background.jpg";
      greeters.gtk = {
        enable = true;
        theme.package = pkgs.arc-theme;
        theme.name = "Arc-Dark";
        indicators = ["~host" "~spacer" "~clock" "~spacer" "~session" "~layout" "~power"];
        iconTheme.package = pkgs.arc-icon-theme;
        iconTheme.name = "Arc";
        extraConfig = "hide-user-image = true";
      };
    };

    videoDrivers = ["nvidia"];
    screenSection = ''
      Monitor "DP-0"
      Option "metamodes" "DP-0: 1920x1080_240 +1920+0, DP-2: 1920x1200 +0+0"
    '';
    extraConfig = ''
      Section "Monitor"
        Identifier "DP-0"
        Option "Primary" "true"
      EndSection
    '';
  };
}
