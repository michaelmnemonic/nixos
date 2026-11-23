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

  # Allow usage of tpm-backed ssh keys
  services.ssh-tpm-agent.enable = true;

  # Enable better ssh experience over bad connections
  programs.mosh.enable = true;
}
