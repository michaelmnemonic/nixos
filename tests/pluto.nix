{agenix}: {
  name = "pluto-boot";

  nodes.machine = {lib, ...}: {
    imports = [
      ../hosts/pluto.nix
      agenix.nixosModules.default
    ];

    # Increase memory and cores for the VM
    virtualisation.memorySize = 2048;
    virtualisation.cores = 2;

    # Override filesystem configuration to be compatible with the test VM
    # The real hardware configuration expects specific partitions and Btrfs subvolumes
    fileSystems = lib.mkForce {
      "/" = {
        device = "/dev/vda";
        fsType = "ext4";
      };
    };

    # Disable LUKS encryption setup expected on real hardware
    boot.initrd.luks.devices = lib.mkForce {};

    # Disable fan2go service as hardware sensors are not available in VM
    systemd.services.fan2go.enable = lib.mkForce false;

    # Resolve conflict with test-instrumentation
    boot.consoleLogLevel = lib.mkForce 0;

    # Prevent conflict with the externally created nixpkgs instance
    nixpkgs.config = lib.mkForce {};
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("echo 'Pluto configuration booted successfully!'")
  '';
}
