{pkgs, ...}: {
  # Enable printing
  services.printing = {
    enable = true;
    drivers = [pkgs.hplip];
  };
  hardware.printers = {
    # Setup default printers
    ensurePrinters = [
      {
        name = "Laserdrucker";
        location = "Flur";
        deviceUri = "ipp://B432-820DB6/ipp";
        model = "everywhere";
        ppdOptions = {
          PageSize = "A4";
          Duplex = "DuplexNoTumble";
        };
      }
    ];
    ensureDefaultPrinter = "Laserdrucker";
  };
}
