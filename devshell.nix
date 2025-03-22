{pkgs}:
pkgs.mkShell {
  # Packages
  packages = with pkgs; [
    gitMinimal
    nil
    alejandra
  ];

  # Environment variables
  env = {};

  # Custom bash code
  shellHook = ''

  '';
}
