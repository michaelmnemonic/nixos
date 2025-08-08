let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3kkcIDgxOfC8xXkoPLR4g+nK0dgT1hbmLAcAKKk7QI";
  maik_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfEOsO8EXO+oW8sisd+JHrT6FrvnuY+1xAVPEz5Prhm";
  users = [maik_charon maik_pluto];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLkKCEvsR2Tq9fOuTzpYXWUJIeyndlTX6rgUEIaFuUC";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEFn+etfEQXxsj9be8x40LrBqgVcFtlxVCqbLtCbeRuK";
  systems = [charon pluto];
in {
  #  "charon-private.key.age".publicKeys = users ++ systems;
  #  "orpheus_charon.psk.age".publicKeys = users ++ systems;
  "pluto-private.key.age".publicKeys = users ++ systems;
  "orpheus_pluto.psk.age".publicKeys = users ++ systems;
}
