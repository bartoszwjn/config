{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.zsh;
in
{
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
        ls = "eza --group-directories-first";
        l = "ls --long --all --header --group --binary --time-style=iso";
        ll = "l --git --git-repos --total-size";
        t = "ls --tree";
        tl = "t --long --header --group --binary --time-style=iso";
        tll = "tl --git --git-repos --total-size";
        ta = "t --all";
        tla = "tl --all";

        ga = "git add";
        gb = "git branch";
        gc = "git commit";
        gdf = "git diff";
        gf = "git fetch";
        gl = "git log --all --oneline --graph";
        gm = "git merge --ff-only";
        gpl = "git pull";
        gps = "git push";
        grb = "git rebase";
        gsh = "git show";
        gspp = "git stash pop";
        gsps = "git stash push";
        gst = "git status";
        gsw = "git switch";

        nb = "nix build --no-link --print-out-paths --log-format multiline";
        nd = "nix develop --log-format multiline";
        ne = "nix eval";
        nfc = "nix flake check --log-format multiline";
        nr = "nix run --log-format multiline";
        ns = "nix shell --log-format multiline";

        btctl = "bluetoothctl";
        diff = "diff --color";
        j = "just";
        lsblk = "lsblk -o NAME,MAJ:MIN,RM,TYPE,RO,SIZE,MOUNTPOINTS,LABEL,FSTYPE,PARTTYPENAME,UUID";
        sctl = "systemctl";
      };

      envExtra = ''
        typeset -U PATH path
      '';

      initContent = ''
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
          $shell$git_branch$git_commit$git_status$git_state$package$python$rust
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

    programs.zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
