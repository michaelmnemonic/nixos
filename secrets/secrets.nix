let
  maik_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL3kkcIDgxOfC8xXkoPLR4g+nK0dgT1hbmLAcAKKk7QI";
  users = [maik_charon];

  charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINLkKCEvsR2Tq9fOuTzpYXWUJIeyndlTX6rgUEIaFuUC";
  systems = [charon];
in {
  "charon-private.key.age".publicKeys = users ++ systems;
}
