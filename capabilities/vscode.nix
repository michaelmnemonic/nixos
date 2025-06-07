{pkgs, ...}: let
  inherit (pkgs) vscode-extensions vscode-with-extensions;

  continue = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "continue";
      publisher = "Continue";
      version = "1.1.40";
      sha256 = "sha256-P4rhoj4Juag7cfB9Ca8eRmHRA10Rb4f7y5bNGgVZt+E=";
      arch = "linux-x64";
    };
    # Patch obtained from: https://github.com/continuedev/continue/issues/821
    nativeBuildInputs = [pkgs.autoPatchelfHook];
    buildInputs = [pkgs.stdenv.cc.cc.lib];
  };

  vscode = vscode-with-extensions.override {
    vscodeExtensions = with vscode-extensions; [
      continue
      jnoortheen.nix-ide
      mkhl.direnv
      ms-vscode-remote.remote-ssh
    ];
  };
in {
  environment.systemPackages = with pkgs; [
    vscode
  ];

  # VSCode shall use native wayland
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
