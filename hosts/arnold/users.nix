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
        extraGroups = [
          "wheel"
        ];
        openssh.authorizedKeys.keyFiles = [
          privateConfig.hosts.blue.bartoszwjn.ssh.publicKeyFile
          privateConfig.hosts.green.bartoszwjn.ssh.publicKeyFile
        ];
      };
    };
  };
}
