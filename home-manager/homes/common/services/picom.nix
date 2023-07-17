{
  config,
  lib,
  pkgs,
  ...
}: {
  services.picom = {
    enable = true;
    vSync = true;
    settings = {
      detect-client-opacity = true;
      detect-transient = true;
      detect-client-leader = true;
      glx-no-stencil = true;
      glx-copy-from-front = false;
      mark-wmwin-focused = true;
      mark-ovredir-focused = false;
      use-ewmh-active-win = true;
      xrender-sync-fence = true;
      log-level = "info";
    };
  };
}
