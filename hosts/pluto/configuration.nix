{
  flake,
  inputs,
  perSystem,
  ...
}: {
  imports = [
    # Shared host configuration
    inputs.self.nixosModules.hosts-shared
    # Hardware configuration
    inputs.self.nixosModules.hardware-pluto
  ];

  # Network configuration
  networking.hostName = "pluto";

  system.stateVersion = "24.05";
}
