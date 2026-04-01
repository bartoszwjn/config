{
  config,
  lib,
  pkgs,
  ...
}:

{
  assertions = [
    {
      assertion = config.boot.loader.supportsInitrdSecrets == true;
      message = "Boot loader doesn't support initrd secrets";
    }
    {
      assertion = config.boot.initrd.systemd.network.networks != { };
      message = "no networks configured for stage 1 systemd-networkd";
    }
  ];

  environment.systemPackages = [
    pkgs.sbctl # secure boot
    pkgs.tpm2-tss # required for unlocking LUKS devices with TPM2
  ];

  boot.loader.systemd-boot.enable = false;
  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
    settings.editor = false;
  };
  boot.loader.timeout = 1;

  boot.kernelModules = [ "kvm-amd" ];

  boot.initrd = {
    kernelModules = [ "dm-snapshot" ];
    availableKernelModules = [
      "aesni_intel"
      "ahci"
      "cryptd"
      "nvme"
      "r8169" # ethernet
      "sd_mod"
      "xhci_pci"
    ];

    systemd.enable = true;

    network.enable = true;
    network.ssh = {
      enable = true;
      port = 2222; # ssh port during boot for luks decryption
      hostKeys = [ "/etc/ssh/stage1_ssh_host_ed25519_key" ];
      authorizedKeys =
        let
          getUserKeys =
            user:
            let
              inherit (config.users.users.${user}.openssh.authorizedKeys) keys keyFiles;
            in
            keys ++ map builtins.readFile keyFiles;
        in
        builtins.concatMap getUserKeys [
          "bartoszwjn"
        ];
    };

    secrets = {
      "/etc/ssh/stage1_ssh_host_ed25519_key" = "/etc/ssh/stage1_ssh_host_ed25519_key";
    };

    systemd.contents."/etc/profile".text = ''
      systemctl default
    '';
  };
}
