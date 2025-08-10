{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    configure= {
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          ctrlp
          nvim-lspconfig
          vim-nix
        ];
      };
    };
  };
}
