{lib}: {
  isAllowed = pkg:
    builtins.elem (lib.getName pkg) [
      "discord"
      "obsidian"
      "slack"
      "spotify"
    ];
}
