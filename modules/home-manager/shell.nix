{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.custom.shell;
in
{
  options.custom.shell = {
    enable = lib.mkEnableOption "common shell configuration";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.fzf # zoxide
    ];

    programs.direnv = {
      enable = true;
      nix-direnv = {
        enable = true;
        package = osConfig.custom.nix.lixPackageSet.nix-direnv;
      };
    };

    programs.starship = {
      enable = true;
      settings = {
        format = ''
          $username$hostname$time$directory$cmd_duration
          $shell$git_branch$git_commit$git_status$git_state$package$python$rust$direnv
           $shlvl$jobs$status$character
        '';
        add_newline = true;
        scan_timeout = 30;
        command_timeout = 200;
        cmd_duration = {
          min_time = 1000;
          show_milliseconds = true;
        };
        directory = {
          fish_style_pwd_dir_length = 1;
          format = "in [$path]($style) [$read_only]($read_only_style)";
          style = "bold blue";
          truncate_to_repo = false;
          truncation_length = 5;
        };
        direnv = {
          disabled = false;
          format = "[$symbol]($style)( [$loaded](green))( [$allowed](red)) ";
          symbol = "direnv";
          style = "none";
          loaded_msg = "loaded";
          unloaded_msg = "";
          allowed_msg = "";
          not_allowed_msg = "not allowed";
          denied_msg = "denied";
        };
        git_commit = {
          style = "bold purple";
        };
        hostname = {
          format = "[@$hostname]($style) ";
          ssh_only = false;
          trim_at = "";
        };
        jobs = {
          threshold = 1;
        };
        python = {
          style = "bold blue";
          symbol = " ";
        };
        rust = {
          style = "bold yellow";
          symbol = " ";
        };
        shell = {
          disabled = false;
          style = "bright-black";
        };
        shlvl = {
          disabled = false;
          symbol = "≡";
        };
        status = {
          disabled = false;
          symbol = "";
        };
        time = {
          disabled = false;
          format = "at [$time]($style) ";
          style = "green";
        };
        username = {
          format = "[$user]($style)";
          show_always = true;
        };
      };
    };

    programs.zoxide.enable = true;
  };
}
