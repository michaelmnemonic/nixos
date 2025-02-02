{...}: {

  # Enable davfs
  services.davfs2 = {
    enable = true;
    settings = {
      "secrets" = /home/maik/.config/davfs2/secrets;
    }
  };

  # Auto mount orpheus
  systemd.mounts = [
    {
      type = "davfs";
      mountConfig = {
        Options = "rw,user,uid=maik,noatime";
        ForceUnmount = true;
      };
      what = "https://orpheus.42evy4oo6scnaepd.myfritz.net/";
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
