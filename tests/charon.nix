{
  agenix,
  nixos-x13s,
}: {
  name = "charon";

  nodes.machine = {lib, ...}: {
  };

  testScript = ''
    pass
  '';
}
