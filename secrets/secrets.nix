let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAkpHhxgnv0LKZE0evDYtOqxlWKdIoycoknSJWrJ7bUX";
  maik_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHiDzhputQHdP2A9AiLHEUirFPQIkk5v9r/geOjOO6lP";
  maik_juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdpU8lQTPUVpDxIQ8cyqBFTfGfxBNkNtIxfNa8NHger maik@juno";
  users = [
    maik_charon
    maik_pluto
    maik_juno
  ];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILNYvp3EZuiCy9ttnBKeV2/+XWblB0hmHwsAKOkTL/Bw";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIZNb1ud7fDrGm14BwJtkL3p25myjyMaN0cRiIHr2jNl";
  juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBgX0SJ0x/vYTxM+q8AS0fGNJA8Kh4CVf6Scvtf1UGB0";
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
}
