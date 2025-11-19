{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.shell.starship;

  gitModules = [
    "git_branch"
    "git_commit"
    "git_status"
    "git_state"
  ];
in
{
  options.custom.shell.starship = {
    enable = lib.mkEnableOption "starship shell prompt";
  };

  config = lib.mkIf cfg.enable {
    programs.starship = {
      enable = true;
      settings = {
        format =
          let
            vcs = lib.concatMapStrings (s: "\${custom.${s}}") (gitModules ++ [ "jj" ]);
          in
          ''
            $username$hostname$time$directory$cmd_duration
            $shell$direnv$package$python$rust${vcs}
             $shlvl$jobs$status$character
          '';
        add_newline = true;
        scan_timeout = 30;
        command_timeout = 200;
        cmd_duration = {
          min_time = 1000;
          show_milliseconds = true;
        };
        custom = {
          jj = {
            description = "Show current jj status";
            shell = [ "sh" ];
            when = "jj root --ignore-working-copy";
            format = "on $output ";
            command =
              let
                bold = ''\e[1m'';
                green = ''\e[32m'';
                red = ''\e[31m'';
                reset = ''\e[0m'';
              in
              ''
                to_wc=$(
                  jj log --no-graph --revisions 'trunk()..@-' --template 1
                )
                if [ "''${#to_wc}" -gt 0 ]; then
                  printf "${bold}%s${green}+${reset} " "''${#to_wc}"
                fi

                to_trunk=$(
                  jj log --ignore-working-copy --no-graph --revisions '@..trunk()' --template 1
                )
                if [ "''${#to_trunk}" -gt 0 ]; then
                  printf "${bold}%s${red}-${reset} " "''${#to_trunk}"
                fi

                jj log --ignore-working-copy --no-graph --color always --revisions @ --template '
                  separate(" ",
                    change_id.shortest(8),
                    truncate_end(50, bookmarks, "…"),
                    label("separator", "|"),
                    concat(
                      if(conflict, label("conflict", " ")),
                      if(divergent, label("divergent", " ")),
                      if(immutable, " "),
                      if(hidden, "󰊠 "),
                    ),
                    if(empty, label("log commit empty", "(empty)")),
                    label(
                      separate(" ",
                        "log commit",
                        if(description.len() == 0 && empty, "empty"),
                        "description",
                        if(description.len() == 0, "placeholder"),
                      ),
                      coalesce(
                        truncate_end(72, description.first_line(), "…"),
                        "(no description set)",
                      ),
                    ),
                  )
                '
              '';
          };
        }
        // lib.genAttrs gitModules (module: {
          description = "Show ${module} only if we're not in a jj repo";
          shell = [ "sh" ];
          when = "! jj root --ignore-working-copy";
          format = "($output )";
          command = "starship module ${module}";
        });
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

    programs.starship.enableZshIntegration = true;

    custom.shell.nu.extraAutoloadFiles."starship.nu" =
      pkgs.runCommand "starship-nushell-config.nu"
        { nativeBuildInputs = [ config.programs.starship.package ]; }
        ''
          starship init nu > "$out"
        '';
  };
}
