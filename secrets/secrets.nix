let
  maik_at_pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHDvt6BOPNRAzNIGukbsJmK6heRNjuuN5p0uc7RXH9zf";
  maik_at_charon = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICfbWSyDza2x5JhQW2oFHoDmO2FEqlrTHRKqe5f/GB2A";
  users = [ maik_at_pluto maik_at_charon ];

  orpheus = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCu5eDTW17n9dNFdFhv4B/SDgOwtkKlxYdmwuoXZlPL8U74coDfqeCssTS3iaH43sLeLBesqG4hTghORxkIsaF9Nr+So29eFhqPeSPye50XwcrMkdCPGdjkdOgo6MijEWC0ucdp4EIqRJMppWGOicv3Ot36pPzoVkMcfDGyafgrWnxiZhkRxR2/tXHelWdTSlBf/UIPMxCPNS9itr1jf9IEEoAfvp/1i7BBbynBpOdHcjRoDZnKcC/QN787NwzTwFG8Hq7KRufUg+4t19PQCcaFNf9wUpLDBgboNES7F4XcGw4EL79rNohhP89azSKz63Do5yB+QOmBL7fGvktnyexFhKDNBagRqVuqSxy3RodmhWaLCJuoavAnzSkWYsv3bJafxgI5alMY09iBF1lzXtGg/dSovNjwaymC1v2x6mhgtPmEaQWIzbpk7aYPxNOHa6iScqgDO0XfAD7nszo82mEjjhWqSRFoTKXBY6L8PKZNCbX1ugz7j0FQA1narJnxBg4d0NfvWfc57C//uMIb7cRwCRmKETWz/ElFSBGpUHchrvl2xH2UM+mgCQ9wxAVXLhN8aAEJfNqX9SPYaOLORqeMtQHSIAnug9O099GdbIWSYVpBjqRskeH/I/lUwYGBsHBQKVI2wFVTYuBc4yHtpw5Gv13YUn43Y7Ud3kBNJQUlkQ==
";
  pluto = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAVSEJEr0nIxTeQrZ/6rMwf60aM5F8P0HVFBlQllm1Ii";
  systems = [ orpheus pluto ];
in
{
  "nix-cache-host.age".publicKeys = users ++ systems;
  "nix-cache-host-key.age".publicKeys = users ++ systems;
}
