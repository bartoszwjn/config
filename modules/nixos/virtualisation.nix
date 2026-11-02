{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.custom.virtualisation;
in
{
  options.custom.virtualisation = {
    podman.enable = lib.mkEnableOption "podman";
    virt-manager.enable = lib.mkEnableOption "virt-manager";
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.podman.enable { virtualisation.podman.enable = true; })

    (lib.mkIf cfg.virt-manager.enable {
      programs.virt-manager.enable = true;
      virtualisation.libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";
        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = false;
        };
      };
    })
  ];
}
