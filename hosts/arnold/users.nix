{
  config,
  lib,
  pkgs,
  privateConfig,
  ...
}:

{
  users = {
    mutableUsers = false;
    users = {
      bartoszwjn = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
        openssh.authorizedKeys.keyFiles = [
          # keep-sorted start
          privateConfig.hosts.blue.bartoszwjn.ssh.publicKeyFile
          privateConfig.hosts.firebrick.ssh.publicKeyFile
          privateConfig.hosts.green.bartoszwjn.ssh.publicKeyFile
          # keep-sorted end
        ];
        shell = pkgs.zsh;
      };
    };
  };
}
