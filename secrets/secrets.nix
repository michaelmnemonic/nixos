let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAmb+q8bEcWZi6kZ6DeedUP7wPR3re98O9yWmlyxwAgm";
  maik_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfEOsO8EXO+oW8sisd+JHrT6FrvnuY+1xAVPEz5Prhm";
  maik_juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdpU8lQTPUVpDxIQ8cyqBFTfGfxBNkNtIxfNa8NHger maik@juno";
  users = [maik_charon maik_pluto maik_juno];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINkU1hUUcTp+nlGq8vhnbJeRxyolxYoW8bSRACt3xREJ";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFn+etfEQXxsj9be8x40LrBqgVcFtlxVCqbLtCbeRuK";
  juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgX0SJ0x/vYTxM+q8AS0fGNJA8Kh4CVf6Scvtf1UGB0";
  flore = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGa1hvRBpAFaN2zU1zQXt3l0/CvHypQ4WGhcsG8GB0sf";
  systems = [charon pluto juno flore];
in {
  "charon-private.key.age".publicKeys = users ++ systems;
  "orpheus_charon.psk.age".publicKeys = users ++ systems;
  "pluto-private.key.age".publicKeys = users ++ systems;
  "orpheus_pluto.psk.age".publicKeys = users ++ systems;
  "juno-private.key.age".publicKeys = users ++ systems;
  "orpheus_juno.psk.age".publicKeys = users ++ systems;
  "flore-private.key.age".publicKeys = users ++ systems;
  "orpheus_flore.psk.age".publicKeys = users ++ systems;
}
