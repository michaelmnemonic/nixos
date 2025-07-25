{...}: let
  ssh_keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDvt6BOPNRAzNIGukbsJmK6heRNjuuN5p0uc7RXH9zf maik@pluto"
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfbWSyDza2x5JhQW2oFHoDmO2FEqlrTHRKqe5f/GB2A maik@charon"
  ];
in {
  users.users.maik = {
    isNormalUser = true;
    description = "Maik Köhler";
    initialHashedPassword = "$y$j9T$BxQsIrZDobn4n7SRol8QE1$BNhg4USV5qCboQab8zQJex6BQCJN6rQiF4fDnXG/Mz6";
    extraGroups = ["wheel" "kvm" "docker" "networkmanager"]; # Enable ‘sudo’ for the user.
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
