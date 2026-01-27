{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (
      mpv.override {
        scripts = with pkgs.mpvScripts; [
          dynamic-crop
          sponsorblock
        ];
      }
    )
  ];
}
