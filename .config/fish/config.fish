if test -d /home/linuxbrew/.linuxbrew
    /home/linuxbrew/.linuxbrew/bin/brew shellenv | source
end

# System & User Binaries
fish_add_path ~/.local/bin

if status is-interactive
    # Load Aliases
    source ~/.config/fish/alias.fish

    # Initialize Starship Prompt (Placed at the end)
    starship init fish | source
end
