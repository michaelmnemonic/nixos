{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  packages = with pkgs; [
    gitMinimal
    nil
    alejandra
  ];
}
