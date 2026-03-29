# System & User Binaries
fish_add_path ~/.local/bin

if status is-interactive

    # AI (Cursor at the placeholder for your prompt/input)
    abbr -a ai 'ramalama run ollama://qwen3.5:9b'

    # System Control (Cursor after the command to type the service name)
    abbr -a sc --set-cursor 'sudo systemctl %'
    abbr -a scu --set-cursor 'systemctl --user %'

    # Tmux Management
    abbr -a ta --set-cursor 'tmux attach-session -t %'
    abbr -a tl 'tmux list-sessions'
    abbr -a tn --set-cursor 'tmux new-session -s %'
    abbr -a ts --set-cursor 'tmux switch-client -t %'

    # Git Workflow
    abbr -a ga --set-cursor 'git add %'
    abbr -a gc --set-cursor 'git commit -m "%"'
    abbr -a gl 'git pull'
    abbr -a gp 'git push'
    abbr -a gco --set-cursor 'git checkout %'

    # Laravel Helpers
    abbr -a pa --set-cursor 'php artisan %'
    abbr -a mfs 'php artisan migrate:fresh --seed'

    # Initialize Starship Prompt (Placed at the end)
    starship init fish | source

end

