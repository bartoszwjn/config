{
  lib,
  neovim,
  runCommand,
  vimPlugins,
  vimUtils,
}:
let
  config = vimUtils.buildVimPlugin {
    name = "config";
    src = ../neovim;
  };

  inherit (vimPlugins) nvim-treesitter;
  nvim-treesitter-with-plugins = nvim-treesitter.withPlugins (
    ps: nvim-treesitter.allGrammars ++ [ ps.tree-sitter-nu ]
  );

  nvim-treesitter-fixed = nvim-treesitter-with-plugins.overrideAttrs (old: {
    passthru.dependencies =
      assert lib.count isNuGrammar old.passthru.dependencies == 1;
      map (drv: if isNuGrammar drv then fixupNuQueries drv else drv) old.passthru.dependencies;
  });
  isNuGrammar = drv: lib.getName drv == "vimplugin-treesitter-grammar-nu";
  fixupNuQueries =
    drv:
    runCommand "vimplugin-treesitter-grammar-nu" { meta = drv.meta; } ''
      cp -r ${drv} $out
      chmod u+w $out/queries $out/queries/nu
      mv -n $out/queries/nu $out/queries/nu-old
      mv -n $out/queries/nu-old/nu $out/queries/nu
      rmdir $out/queries/nu-old
    '';
in
neovim.override {
  withPython3 = false;
  withRuby = false;
  configure = {
    customRC = ''
      source ${config}/init.lua
    '';
    packages.custom.start = builtins.attrValues {
      inherit config;
      inherit (vimPlugins)
        cmp-cmdline
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-path
        cmp_luasnip
        comment-nvim
        diffview-nvim # required by neogit
        fidget-nvim
        friendly-snippets
        git-messenger-vim
        gitsigns-nvim
        indent-blankline-nvim
        leap-nvim
        luasnip
        neodev-nvim
        neogit
        nvim-autopairs
        nvim-cmp
        nvim-lspconfig
        nvim-surround
        nvim-treesitter-textobjects
        onedark-nvim
        plenary-nvim # required by neogit, telescope-nvim
        rainbow-delimiters-nvim
        substitute-nvim
        telescope-nvim # required by neogit
        ;
      nvim-treesitter = nvim-treesitter-fixed;
    };
  };
}
