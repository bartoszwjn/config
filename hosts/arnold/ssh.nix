{
  config,
  lib,
  pkgs,
  ...
}:

{
  services.openssh = {
    enable = true;
    settings = {
      AuthenticationMethods = "publickey";
      PermitRootLogin = "prohibit-password";
    };
  };
}
