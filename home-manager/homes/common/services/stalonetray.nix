{
  config,
  lib,
  pkgs,
  ...
}: {
  options.services.stalonetray.geometry = lib.mkOption {
    type = lib.types.str;
  };

  config.services.stalonetray = {
    enable = true;
    config = {
      background = "#1c1e25";
      geometry = config.services.stalonetray.geometry;
      grow_gravity = "NE";
      icon_gravity = "NE";
      kludges = "force_icons_size";
      skip_taskbar = true;
      sticky = true;
      window_layer = "bottom";
      window_type = "dock";
    };
  };
}
