{neovim}:
neovim.override {
  withPython3 = false;
  withRuby = false;
  configure = {
    customRC = ''
      source ${./config.lua}
    '';
  };
}
