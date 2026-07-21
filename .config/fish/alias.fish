# System Administration
abbr -a sc 'sudo systemctl'
abbr -a scu 'systemctl --user'
abbr -a scl 'sudo journalctl -u.service -f'
abbr -a jf 'journalctl -xf -n 1000'

# Applications
abbr -a bup 'brew update; and brew upgrade; and brew cleanup'
abbr -a ai 'ramalama run ollama://qwen2.5-coder:7b'
abbr -a vsc 'flatpak run com.visualstudio.code .'

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
