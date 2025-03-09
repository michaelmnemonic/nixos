{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  packages = [
    pkgs.gitMinimal
    pkgs.nil
    pkgs.alejandra
  ];
}
