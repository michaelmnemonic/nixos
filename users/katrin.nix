{...}: {
  users.users.katrin = {
    isNormalUser = true;
    description = "Katrin Köhler";
    initialHashedPassword = "$y$j9T$BxQsIrZDobn4n7SRol8QE1$BNhg4USV5qCboQab8zQJex6BQCJN6rQiF4fDnXG/Mz6";
    extraGroups = []; # Enable ‘sudo’ for the user.
  };
}
