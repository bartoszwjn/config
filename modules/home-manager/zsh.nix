{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.custom.zsh;
in {
  options.custom.zsh = {
    enable = lib.mkEnableOption "zsh with custom config";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      pkgs.fzf # zoxide
      pkgs.zsh-completions
    ];

    programs.zsh = {
      enable = true;
      autosuggestion.enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      defaultKeymap = "emacs";
      history = {
        expireDuplicatesFirst = true;
        extended = true;
        ignoreDups = true; # merges consecutive duplicated lines
        ignoreSpace = true; # lines starting with space are not added to history
        save = 10000; # number of lines to save in history file
        share = true; # append lines to history file as soon as they are entered
        size = 10000; # number of lines to store in memory
      };
      historySubstringSearch = {
        enable = true;
        # NixOS rebinds arrows from "^[[A" to "^[OA", etc
        # https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/programs/zsh/zinputrc
        # https://wiki.archlinux.org/title/Zsh#Key_bindings
        searchUpKey = "^[OA";
        searchDownKey = "^[OB";
      };

      localVariables = {
        sd = config.custom.repo.configRepoRoot + "/scripts";
      };
      shellAliases = {
        ls = "ls --color=auto";
        ll = "ls -lh --group-directories-first";
        l = "ls -lhA --group-directories-first";

        gl = "git log --all --oneline --graph";

        sctl = "systemctl";
        btctl = "bluetoothctl";
        j = "just";
        tree = "tree -C";
        lsblk = "lsblk -o NAME,MAJ:MIN,RM,TYPE,RO,SIZE,MOUNTPOINT,LABEL,FSTYPE,PARTTYPENAME,UUID";
      };

      envExtra = ''
        typeset -U PATH path
      '';

      initExtra = ''
        setopt nomatch notify
        unsetopt autocd beep

        # Disable terminal controls bound by default to ^Q ^S ^U ^O ^V ^R ^W
        stty start undef stop undef kill undef
        stty discard undef lnext undef rprnt undef werase undef

        # move by words with Ctrl+Arrow, see https://wiki.archlinux.org/title/Zsh#Key_bindings
        typeset -A key
        key[Control-Left]="''${terminfo[kLFT5]}"
        key[Control-Right]="''${terminfo[kRIT5]}"
        [[ -n "''${key[Control-Left]}" ]] && bindkey -- "''${key[Control-Left]}" backward-word
        [[ -n "''${key[Control-Right]}" ]] && bindkey -- "''${key[Control-Right]}" forward-word

        function dup () {
            if (( $# > 1 )) then
                echo "dup: expected at most one argument"
                return 1
            fi
            if [[ $TERM != "alacritty" ]]; then
                echo "dup: current terminal is not alacritty"
                return 1
            fi
            if (( $# == 0 )) then
                alacritty&!
            else
                repeat $1 do
                    alacritty&!
                done
            fi
        }

        function mcd () {
            if (( $# != 1 )) then
              echo "mcd: expected one argument"
              return 1
            fi
            mkdir -p $1 && cd $1
        }
      '';
    };

    programs.direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    programs.starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        format = ''
          $username$hostname$time$directory$cmd_duration
          $git_branch$git_commit$git_status$git_state$package$python$rust
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

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
