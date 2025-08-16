{...}: {
  users.users.katrin = {
    isNormalUser = true;
    description = "Katrin Köhler";
    uid = 1001;
    initialHashedPassword = "";
    extraGroups = []; # Enable ‘sudo’ for the user.
  };
}
