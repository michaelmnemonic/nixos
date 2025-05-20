{...}: {
  users.users.root = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = users.users.maik.openssh.authorizedKeys.keys;
  };
}
