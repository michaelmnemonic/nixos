let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIG9aDwc6iRlynxbDm8bCNq0ufk+yenK+r9/9PcBHVDjG";
  maik_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQLCaKYlzfz1qRSIyGWRKBSiOvq2uS1g9ymhIdObQ4o";
  maik_juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFPR6UDyMQN9Bx9mDTRmdO/B1Kdv/4cwV0MA9cYbsbob";
  users = [
    maik_charon
    maik_pluto
    maik_juno
  ];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE/R4C471WzSIdlj4ELMyFxkfJOnEcX1VjNU5tkd6bmh";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEME7emd72akaRqtz+3j/0VsOftHiS8ILO14IARJUk8P";
  juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFLVfnTs0JR37mvWmOfuW9KPMp2cDl7sCGxDE7WP90PV";
  flore = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa1hvRBpAFaN2zU1zQXt3l0/CvHypQ4WGhcsG8GB0sf";
  systems = [
    charon
    pluto
    juno
    flore
  ];
in
{
  "charon-private.key.age".publicKeys = users ++ systems;
  "orpheus_charon.psk.age".publicKeys = users ++ systems;
  "pluto-private.key.age".publicKeys = users ++ systems;
  "orpheus_pluto.psk.age".publicKeys = users ++ systems;
  "juno-private.key.age".publicKeys = users ++ systems;
  "orpheus_juno.psk.age".publicKeys = users ++ systems;
  "flore-private.key.age".publicKeys = users ++ systems;
  "orpheus_flore.psk.age".publicKeys = users ++ systems;
  "llama-cpp-api.key.age".publicKeys = users ++ systems;
}
