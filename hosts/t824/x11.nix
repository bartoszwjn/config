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

    videoDrivers = ["modesetting"];
    screenSection = ''
      Monitor "eDP-1"
    '';
    extraConfig = ''
      Section "Monitor"
        Identifier "eDP-1"
        Option "Primary" "true"
      EndSection

      Section "Monitor"
        Identifier "HDMI-1"
        Option "Position" "0 0"
      EndSection
    '';
  };

  services.libinput = {
    enable = true;
    touchpad = {
      clickMethod = "clickfinger";
      disableWhileTyping = true;
      horizontalScrolling = true;
      middleEmulation = false;
      naturalScrolling = true;
      scrollMethod = "twofinger";
      tapping = true;
      tappingButtonMap = "lrm";
      tappingDragLock = true;
    };
  };
}
