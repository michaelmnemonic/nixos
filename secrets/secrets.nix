let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIILpZoy2khZNpMO05fNXVIB/6OWqarzgv7OOubj+JWgH";
  maik_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfEOsO8EXO+oW8sisd+JHrT6FrvnuY+1xAVPEz5Prhm";
  maik_juno = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMdpU8lQTPUVpDxIQ8cyqBFTfGfxBNkNtIxfNa8NHger maik@juno";
  users = [maik_charon maik_pluto maik_juno];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPoesBYo+KX7Xn9svwOt3qqO6hMHwlDN+vuhiSvFFSpD";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFn+etfEQXxsj9be8x40LrBqgVcFtlxVCqbLtCbeRuK";
  systems = [charon pluto];
in {
  "charon-private.key.age".publicKeys = users ++ systems;
  "orpheus_charon.psk.age".publicKeys = users ++ systems;
  "pluto-private.key.age".publicKeys = users ++ systems;
  "orpheus_pluto.psk.age".publicKeys = users ++ systems;
}
