{
  agenix,
  nixos-x13s,
  vibepanel,
  voxtype,
}: {
  name = "charon";

  nodes.machine = {lib, ...}: {
  };

  testScript = ''
    pass
  '';
}
