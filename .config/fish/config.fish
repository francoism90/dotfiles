# System & User Binaries
fish_add_path ~/.local/bin

if status is-interactive

    # System Administration
    abbr -a sudo --set-cursor 'run0 %'
    abbr -a sc --set-cursor 'run0 systemctl %'
    abbr -a scu --set-cursor 'systemctl --user %'
    abbr -a scl --set-cursor 'run0 journalctl -u %.service -f'
    abbr -a jf --set-cursor 'journalctl -xf -n 100 %'

    # AI (Cursor at the placeholder for your prompt/input)
    abbr -a ai --set-cursor 'ramalama run ollama://qwen2.5-coder:7b %'

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

    # Initialize Starship Prompt (Placed at the end)
    starship init fish | source

end
