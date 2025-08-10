{pkgs, ...}: {
  programs.neovim = {
    enable = true;
    configure = {
      customRC = ''
        set number
        set cc=80
      '';
      packages.myVimPackage = with pkgs.vimPlugins; {
        start = [
          ctrlp
          vim-nix
          nvim-lspconfig
        ];
      };
    };
  };
}
