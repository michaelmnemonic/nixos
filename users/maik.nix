{...}: {
  security.pam.enableFscrypt = true;
  users.users.maik = {
    isNormalUser = true;
    description = "Maik Köhler";
    initialHashedPassword = "$y$j9T$BxQsIrZDobn4n7SRol8QE1$BNhg4USV5qCboQab8zQJex6BQCJN6rQiF4fDnXG/Mz6";
    extraGroups = [ "wheel" "kvm" ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = [
    ];
  };
}
