{ ... }:
let
  ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfEOsO8EXO+oW8sisd+JHrT6FrvnuY+1xAVPEz5Prhm maik@pluto"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAkpHhxgnv0LKZE0evDYtOqxlWKdIoycoknSJWrJ7bUX maik@charon"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdpU8lQTPUVpDxIQ8cyqBFTfGfxBNkNtIxfNa8NHger maik@juno"
  ];
in
{
  users.users.maik = {
    isNormalUser = true;
    description = "Maik Köhler";
    uid = 1000;
    initialHashedPassword = "$y$j9T$BxQsIrZDobn4n7SRol8QE1$BNhg4USV5qCboQab8zQJex6BQCJN6rQiF4fDnXG/Mz6";
    extraGroups = [
      "wheel"
      "kvm"
      "docker"
      "networkmanager"
    ]; # Enable ‘sudo’ for the user.
    openssh.authorizedKeys.keys = ssh_keys;
    subUidRanges = [
      {
        count = 65536;
        startUid = 1000000;
      }
    ];
    subGidRanges = [
      {
        count = 65536;
        startGid = 1000000;
      }
    ];
  };
  users.users.root.openssh.authorizedKeys.keys = ssh_keys;
}
