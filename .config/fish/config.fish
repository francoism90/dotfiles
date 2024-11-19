if status is-interactive
    # Commands to run in interactive sessions can go here
end

# system
abbr -a -- sc 'sudo systemctl'
abbr -a -- scu 'systemctl --user'
abbr -a -- tbe 'toolbox enter'
abbr -a -- tbr 'toolbox run'

# tmux
abbr -a -- ta 'tmux attach-session -t'

# apps
abbr -a -- vsc 'flatpak run com.visualstudio.code .'

# git
abbr -a -- ga 'git add'
abbr -a -- gc 'git commit'
abbr -a -- gl 'git pull'
abbr -a -- gp 'git push'
abbr -a -- gco 'git checkout'

starship init fish | source
