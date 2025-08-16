{...}: {
  users.users.katrin = {
    isNormalUser = true;
    description = "Katrin Köhler";
    uid = 1001;
    password = "";
    extraGroups = []; # Enable ‘sudo’ for the user.
  };
}
