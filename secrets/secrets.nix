let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHNHxKH9KqMxSbslkgzBCdMwqrlDzM/+TtlmHuuQJYTT";
  maik_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDPW7zg350UKZ73FKYvcY6OO0M7H23/Z84QF8pSXg1pl";
  maik_juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdpU8lQTPUVpDxIQ8cyqBFTfGfxBNkNtIxfNa8NHger maik@juno";
  users = [
    maik_charon
    maik_pluto
    maik_juno
  ];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBf2HR9GXkOb45zyZjlpsPdkagPXpwMYrwPC8h4L3LUZ";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILCU5RAqeCO4gcln0Cv7QWREYGnJkJ+QwZPv9MfVzL0B";
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
