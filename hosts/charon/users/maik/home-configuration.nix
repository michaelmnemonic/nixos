{...}:{
    # Enable syncthing
    services.syncthing.enable = true;

    # Manage systemd user services
    systemd.user.enable = true;

    home.stateVersion = "24.11";
}
