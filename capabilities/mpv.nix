{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    (
      mpv-unwrapped.wrapper {
        scripts = with pkgs.mpvScripts; [
          dynamic-crop
          sponsorblock
        ];

        mpv = pkgs.mpv-unwrapped;
      }
    )
  ];
}
