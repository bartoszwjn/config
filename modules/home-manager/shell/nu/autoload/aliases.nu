# ls (eza)
alias l = eza --group-directories-first --long --all --header --group --binary --time-style=iso
alias ll = l --git --git-repos --total-size

# tree (eza)
alias t = eza --tree --group-directories-first
alias tl = t --long --header --group --binary --time-style=iso
alias tll = tl --git --git-repos --total-size
alias ta = t --all
alias tla = tl --all
alias tlla = tll --all

# git
alias ga = git add
alias gb = git branch
alias gc = git commit
alias gdf = git diff
alias gf = git fetch
alias gl = git log --all --oneline --graph
alias gm = git merge --ff-only
alias gpl = git pull --ff-only
alias gps = git push
alias grb = git rebase
alias gsh = git show
alias gspp = git stash pop
alias gsps = git stash push
alias gst = git status
alias gsw = git switch

# nix
alias nb = nix build --no-link --print-out-paths --log-format multiline
alias nd = nix develop --log-format multiline
alias ne = nix eval
alias nfc = nix flake check --log-format multiline
alias nr = nix run --log-format multiline
alias ns = nix shell --log-format multiline

# other
alias btctl = bluetoothctl
alias diff = diff --color
alias j = just
alias lsblk = lsblk -o NAME,MAJ:MIN,RM,TYPE,RO,SIZE,MOUNTPOINTS,LABEL,FSTYPE,PARTTYPENAME,UUID
alias sctl = systemctl
