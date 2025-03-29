{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  packages = with pkgs; [
    alejandra
    gitMinimal
    nil
    niv
  ];
}
