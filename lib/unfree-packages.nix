{lib}: {
  isAllowed = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "nvidia-settings"
      "nvidia-x11"
      "slack"
      "spotify"
      "teams"
    ];
}
