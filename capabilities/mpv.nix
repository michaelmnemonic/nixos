{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (mpv.override {
      scripts = with mpvScripts; [
        dynamic-crop
        sponsorblock
      ];
    })
  ];
}
