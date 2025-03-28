{...}:{
    # Enable syncthing
    services.syncthing.enable = true;

    # Manage systemd user services
    systemd.user.enable = true;

    # Dotfiles
    home.file = {
        ".mozilla/firefox/native-messaging-hosts/org.kde.plasma.browser_integration.json".text = ''
            {
                "name": "org.kde.plasma.browser_integration",
                "description": "Native connector for KDE Plasma",
                "path": "/run/current-system/sw/bin/plasma-browser-integration-host",
                "type": "stdio",
                "allowed_extensions": ["plasma-browser-integration@kde.org"]
            }
        '';
    };

    home.stateVersion = "24.11";
}
