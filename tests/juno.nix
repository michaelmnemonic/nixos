{agenix}: {
  name = "juno";

  nodes.machine = {lib, ...}: {
    imports = [
      ../hosts/juno.nix
      agenix.nixosModules.default
    ];

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

    # Disable LUKS encryption setup expected on real hardware
    boot.initrd.luks.devices = lib.mkForce {};

    # Disable swap and resume device which depend on real hardware labels
    swapDevices = lib.mkForce [];
    boot.resumeDevice = lib.mkForce "";
    boot.kernelParams = lib.mkForce ["console=ttyS0"];

    # Prevent conflict with the externally created nixpkgs instance
    nixpkgs.config = lib.mkForce {};

    # Resolve conflict with test-instrumentation
    boot.consoleLogLevel = lib.mkForce 0;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("echo 'Juno configuration booted successfully!'")
  '';
}
