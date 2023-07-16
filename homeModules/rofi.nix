{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.rofi;
in {
  options.custom.rofi = {
    enable = lib.mkEnableOption "Rofi application launcher configuration";
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      terminal = "alacritty";
      cycle = true;
      location = "center";
      theme = "Arc-Dark";
      extraConfig = {
        show-icons = true;
        drun-display-format = "{name}";

        kb-primary-paste = "Control+V";
        kb-secondary-paste = "Control+v";
        kb-clear-line = "Control+d";
        kb-move-front = "Control+a";
        kb-move-end = "Control+e";
        kb-move-word-back = "Control+Left";
        kb-move-word-forward = "Control+Right";
        kb-move-char-back = "Left";
        kb-move-char-forward = "Right";
        kb-remove-word-back = "Control+w,Control+BackSpace";
        kb-remove-char-forward = "Delete";
        kb-remove-char-back = "BackSpace";
        kb-remove-to-eol = "Control+D";
        kb-remove-to-sol = "Control+u";
        kb-accept-entry = "Return,Control+l";
        kb-accept-custom = "Control+Return";
        kb-accept-custom-alt = "Control+Shift+Return,Control+h"; # directory up in filebrowser mode
        kb-accept-alt = "Shift+Return";
        kb-delete-entry = "Shift+Delete";
        kb-mode-next = "Tab,Control+Tab";
        kb-mode-previous = "ISO_Left_Tab,Control+ISO_Left_Tab";
        kb-mode-complete = "Control+o";
        kb-element-next = "Control+j";
        kb-element-prev = "Control+k";
        kb-page-prev = "Control+b";
        kb-page-next = "Control+f";
        kb-cancel = "Escape,Control+g";
        kb-select-1 = "Alt+1";
        kb-select-2 = "Alt+2";
        kb-select-3 = "Alt+3";
        kb-select-4 = "Alt+4";
        kb-select-5 = "Alt+5";
        kb-select-6 = "Alt+6";
        kb-select-7 = "Alt+7";
        kb-select-8 = "Alt+8";
        kb-select-9 = "Alt+9";
        kb-select-10 = "Alt+0";
        kb-custom-1 = "Control+1";
        kb-custom-2 = "Control+2";
        kb-custom-3 = "Control+3";
        kb-custom-4 = "Control+4";
        kb-custom-5 = "Control+5";
        kb-custom-6 = "Control+6";
        kb-custom-7 = "Control+7";
        kb-custom-8 = "Control+8";
        kb-custom-9 = "Control+9";
        kb-custom-10 = "Control+0";
        kb-custom-11 = "Control+Shift+1";
        kb-custom-12 = "Control+Shift+2";
        kb-custom-13 = "Control+Shift+3";
        kb-custom-14 = "Control+Shift+4";
        kb-custom-15 = "Control+Shift+5";
        kb-custom-16 = "Control+Shift+6";
        kb-custom-17 = "Control+Shift+7";
        kb-custom-18 = "Control+Shift+8";
        kb-custom-19 = "Control+Shift+9";
      };
    };
  };
}
