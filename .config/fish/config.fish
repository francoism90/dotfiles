if status is-interactive
    # Commands to run in interactive sessions can go here
end

# system
abbr -a -- sc 'sudo systemctl'
abbr -a -- scu 'systemctl --user'
abbr -a -- tbe 'toolbox enter'
abbr -a -- tbr 'toolbox run'

# containers
abbr -a -- foxws 'podman exec -it systemd-foxws-app'
abbr -a -- hub 'podman exec -it systemd-hub-app'

# apps
abbr -a -- code 'flatpak run com.vscodium.codium '

# git
abbr -a -- ga 'git add'
abbr -a -- gc 'git commit'
abbr -a -- gl 'git pull'
abbr -a -- gp 'git push'
abbr -a -- gco 'git checkout'

starship init fish | source
