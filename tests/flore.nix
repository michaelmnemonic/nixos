{agenix}: {
  name = "flore";

  nodes.machine = {lib, ...}: {
    imports = [
      ../hosts/flore.nix
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

    # Prevent conflict with the externally created nixpkgs instance
    nixpkgs.config = lib.mkForce {};

    # Resolve conflict with test-instrumentation
    boot.consoleLogLevel = lib.mkForce 0;
  };

  testScript = ''
    machine.wait_for_unit("multi-user.target")
    machine.succeed("echo 'Flore configuration booted successfully!'")

    # Check if greetd is running
    machine.wait_for_unit("greetd.service")

    # Check if user katrin (UID 1001) has a wayland session
    # We look for wayland-0 socket in /run/user/1001/
    machine.wait_for_file("/run/user/1001/wayland-0")
    machine.succeed("pgrep -u katrin startplasma")
  '';
}
