# ========================= ls (eza) =========================
# keep-sorted start

alias l = eza --group-directories-first --long --all --header --group --binary --time-style=iso
alias ll = l --git --git-repos --total-size

# keep-sorted end

# ========================= tree (eza) =========================
# keep-sorted start

alias t = eza --tree --group-directories-first
alias ta = t --all
alias tl = t --long --header --group --binary --time-style=iso
alias tla = tl --all
alias tll = tl --git --git-repos --total-size
alias tlla = tll --all

# keep-sorted end

# ========================= git =========================
# keep-sorted start

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

# keep-sorted end

# ========================= nix =========================
# keep-sorted start

alias nb = nix build --no-link --print-out-paths --log-format multiline
alias nd = nix develop --log-format multiline
alias ne = nix eval
alias nfc = nix flake check --log-format multiline
alias nr = nix run --log-format multiline
alias ns = nix shell --log-format multiline

# keep-sorted end

# ========================= other =========================
# keep-sorted start

alias btctl = bluetoothctl
alias diff = diff --color
alias j = just
alias lsblk = lsblk -o NAME,MAJ:MIN,RM,TYPE,RO,SIZE,MOUNTPOINTS,LABEL,FSTYPE,PARTTYPENAME,UUID
alias sctl = systemctl
alias ssh-no-host-key = ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=accept-new

# keep-sorted end
