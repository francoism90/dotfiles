# /etc/fish/conf.d/abbreviations.fish
# Global abbreviation configuration for Fish shell

# Guard: Only execute if the current shell session is interactive.
# Prevents errors in automated non-interactive tasks (scp, rsync, git plumbing).
if status is-interactive

    # System Administration
    abbr -a su 'run0'
    abbr -a sudo 'run0 -i'
    abbr -a sc 'run0 systemctl'
    abbr -a scu 'systemctl --user'
    abbr -a scl 'run0 -i journalctl -f -u' # Fixed spacing for trailing service name
    abbr -a jf 'journalctl -xf -n 1000'
    abbr -a jc 'run0 -i journalctl --vacuum-size=1B'

    # rpm-ostree / Fedora Atomic
    abbr -a rpmst 'rpm-ostree status'
    abbr -a rpmup 'rpm-ostree upgrade'
    abbr -a rpmrb 'rpm-ostree rollback'
    abbr -a rpmclean 'run0 -i rpm-ostree cleanup -p'

    # Flatpak
    abbr -a fpl 'flatpak list'
    abbr -a fpu 'flatpak update'

    # Toolbox / Distrobox
    abbr -a tbe 'toolbox enter'
    abbr -a tbr 'toolbox run'
    abbr -a dbe 'distrobox enter'

    # Listing
    abbr -a la 'ls -A'
    abbr -a lla 'll -A'
    abbr -a llh 'll -h'
    abbr -a llha 'll -hA'

    # Tmux Management
    abbr -a ta 'tmux attach-session -t'
    abbr -a tl 'tmux list-sessions'
    abbr -a tn 'tmux new-session -s'
    abbr -a ts 'tmux switch-client -t'

    # Git Workflow
    abbr -a gs 'git status'
    abbr -a ga 'git add'
    abbr -a gc 'git commit'
    abbr -a gca 'git commit --amend'
    abbr -a gcl 'git clone'
    abbr -a gco 'git checkout'
    abbr -a gp 'git push'
    abbr -a gl 'git pull'
    abbr -a gf 'git fetch'

end
