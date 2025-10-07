{
  pkgs,
  lib,
  ...
}: let
  inherit (pkgs) vscode-extensions vscode-with-extensions;

  continue = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "continue";
      publisher = "Continue";
      version = "1.1.45";
      sha256 = "sha256-5jMRf27p1O0K6x3lSaN2fJLVFv/9mw1zx3LbYoWdeCw=";
      arch = "linux-x64";
    };
    # Patch obtained from: https://github.com/continuedev/continue/issues/821
    nativeBuildInputs = [pkgs.autoPatchelfHook];
    buildInputs = [pkgs.stdenv.cc.cc.lib];
  };

  vscode = vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions;
      [
        catppuccin.catppuccin-vsc
        continue
        jnoortheen.nix-ide
        mkhl.direnv
        ms-python.black-formatter
        ms-python.debugpy
        ms-python.python
        ms-vscode-remote.remote-ssh
      ]
      ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "kde-plasma-breeze";
          publisher = "davidprush";
          version = "1.0.0";
          sha256 = "sha256-wNG8GxP5v687koGOKXXJ520bsr8KmLujK9aSG/XL0rM=";
        }
      ];
  };
in {
  environment.systemPackages = with pkgs; [
    vscode
  ];

  # VSCode shall use native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
