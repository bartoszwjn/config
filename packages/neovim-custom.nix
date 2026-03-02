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
    dependencies = lib.attrValues {
      inherit (vimPlugins)
        cmp-cmdline
        cmp-nvim-lsp
        cmp-nvim-lsp-signature-help
        cmp-path
        cmp_luasnip
        comment-nvim
        diffview-nvim # optional dep for neogit
        fidget-nvim
        friendly-snippets
        git-messenger-vim
        gitsigns-nvim
        indent-blankline-nvim
        lazydev-nvim
        leap-nvim
        luasnip
        neogit
        nvim-autopairs
        nvim-cmp
        nvim-lspconfig
        nvim-surround
        nvim-treesitter-textobjects
        onedark-nvim
        plenary-nvim # required dep for neogit, telescope-nvim
        rainbow-delimiters-nvim
        substitute-nvim
        telescope-nvim # optional dep for neogit
        ;
      nvim-treesitter = nvim-treesitter-with-plugins;
    };
  };

  nvim-treesitter-with-plugins = vimPlugins.nvim-treesitter.withPlugins (
    plugins:
    lib.attrValues {
      inherit (plugins)
        bash
        c
        cpp
        css
        csv
        cue
        desktop
        diff
        dockerfile
        editorconfig
        gitattributes
        gitcommit
        git-config
        gitignore
        git-rebase
        go
        gomod
        groovy
        haskell
        hcl
        hjson
        html
        http
        java
        javascript
        jq
        json
        json5
        jsonnet
        just
        kdl
        kotlin
        lua
        make
        markdown
        nginx
        nix
        nu
        passwd
        perl
        prolog
        proto
        python
        query
        requirements
        rst
        ruby
        rust
        scala
        sql
        ssh-config
        strace
        swift
        terraform
        toml
        tsv
        typescript
        typst
        vim
        xml
        yaml
        zig
        zsh
        ;
    }
  );
in
neovim.override {
  withPython3 = false;
  withRuby = false;
  configure = {
    customRC = ''
      source ${config}/init.lua
    '';
    packages.custom.start = [ config ];
  };
}
