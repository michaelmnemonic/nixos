{...}: {
  # Auto mount orpheus:
  services.rpcbind.enable = true; # needed for NFS
  systemd.mounts = [
    {
      type = "nfs";
      mountConfig = {
        Options = "noatime";
        ForceUnmount = true;
      };
      what = "192.168.178.30:";
      where = "/mnt";
    }
  ];
  systemd.automounts = [
    {
      wantedBy = ["multi-user.target"];
      automountConfig = {
        TimeoutIdleSec = "600";
      };
      where = "/mnt";
    }
  ];
}
