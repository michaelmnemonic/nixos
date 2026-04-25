{...}: {
  # Enable SSH server with public key authentication only
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = true;
    settings.KbdInteractiveAuthentication = true;
  };

  # Enable ssh-agent
  programs.ssh = {
    enableAskPassword = true;
  };

  programs.mosh.enable = true;
}
