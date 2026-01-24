{...}: {
  # Enable SSH server with public key authentication only
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
    settings.KbdInteractiveAuthentication = false;
  };

  # Enable ssh-agent
  programs.ssh = {
    #startAgent = true;
    #enableAskPassword = true;
  };

  programs.mosh.enable = true;
}
