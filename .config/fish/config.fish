if status is-interactive
  # Commands to run in interactive sessions can go here
end

# path
fish_add_path ~/.local/bin

# system
abbr -a -- sc 'sudo systemctl'
abbr -a -- scu 'systemctl --user'

# tmux
abbr -a -- ta 'tmux attach-session -t'
abbr -a -- tl 'tmux list-sessions'
abbr -a -- tn 'tmux new-session -s'
abbr -a -- ts 'tmux switch-client -t'

# apps
abbr -a -- code 'flatpak run com.visualstudio.code --new-window .'

# git
abbr -a -- ga 'git add'
abbr -a -- gc 'git commit'
abbr -a -- gl 'git pull'
abbr -a -- gp 'git push'
abbr -a -- gco 'git checkout'

starship init fish | source
