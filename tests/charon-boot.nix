{
  agenix,
  nixos-x13s,
}: {
  name = "charon-boot";

  nodes.machine = {lib, ...}: {
    imports = [
      ../hosts/charon.nix
      agenix.nixosModules.default
      nixos-x13s.nixosModules.default
    ];

    # Inject nixos-x13s dependency
    _module.args.nixos-x13s = nixos-x13s;

    # Increase memory and cores for the VM
    virtualisation.memorySize = 2048;
    virtualisation.cores = 2;

    # Override filesystem configuration to be compatible with the test VM
    fileSystems = lib.mkForce {
      "/" = {
        device = "/dev/vda";
        fsType = "ext4";
      };
    };

    # Disable the manual btrfs mount for /home/maik which fails on ext4 VM
    systemd.mounts = lib.mkForce [];

    # Disable LUKS encryption setup expected on real hardware
    boot.initrd.luks.devices = lib.mkForce {};

    # Prevent conflict with the externally created nixpkgs instance
    nixpkgs.config = lib.mkForce {};

    # Resolve conflict with test-instrumentation
    boot.consoleLogLevel = lib.mkForce 0;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("echo 'Charon configuration booted successfully!'")
  '';
}
