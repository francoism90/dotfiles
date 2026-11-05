# /etc/fish/conf.d/alias.fish
# Global alias configuration for Fish shell

# Guard: Only execute if the current shell session is interactive.
if status is-interactive

    # Relabel moved files for their destination (SELinux)
    alias mv='mv -Z'

    # Fedora Fish defaults include 'll', but explicit definition ensures
    # safety inside minimal Distrobox/Toolbox containers.
    if not functions -q ll
        alias ll='ls -l'
    end

    # VS Code (Flatpak)
    alias vsc='flatpak run com.visualstudio.code'
    alias code='flatpak run com.visualstudio.code'

end
