{pkgs, ...}:{
    # Enable syncthing
    services.syncthing.enable = true;

    # Manage systemd user services
    systemd.user.enable = true;

    # Install user packages
    home.packages = with pkgs; [
        zed-editor
    ];

    # Dotfiles
    home.file = {
        # mpv
        ".config/mpv/mpv.conf".text = ''
            profile=high-quality
            vo=gpu-next
            gpu-api=vulkan
            gpu-context=waylandvk
        '';
        ".config/mpv/input.conf".text = ''
            WHEEL_UP      seek  10
            WHEEL_DOWN    seek -10
        '';

        # kwin window rules
        ".config/kwinrulesrc".text = ''
            [General]
            count=1
            rules=dd064355-b15d-4681-a245-b7b757480f63

            [dd064355-b15d-4681-a245-b7b757480f63]
            Description=Dark mode für mpv
            decocolor=BreezeDark
            decocolorrule=2
            wmclass=mpv
            wmclassmatch=1
        '';
    };

    home.stateVersion = "24.11";
}
