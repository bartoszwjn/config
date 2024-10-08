{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot = {
    kernelModules = [
      # https://github.com/DHowett/framework-laptop-kmod?tab=readme-ov-file#usage
      "cros_ec"
      "cros_ec_lpcs"

      "kvm-amd"
    ];
    kernelParams = [ "amd_pstate=active" ];
    extraModulePackages = [ config.boot.kernelPackages.framework-laptop-kmod ];
  };

  environment.systemPackages = [ pkgs.framework-tool ];

  hardware = {
    amdgpu.initrd.enable = true;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    cpu.amd.updateMicrocode = true;
    enableRedistributableFirmware = true;
    keyboard.zsa.enable = true;
    logitech.wireless.enable = true;
    sensor.iio.enable = true;
  };

  powerManagement.cpuFreqGovernor = "powersave";

  services.fstrim.enable = true;

  services.fwupd.enable = true;

  services.power-profiles-daemon.enable = true;
  services.tlp.enable = false;

  services.udev.extraRules =
    let
      mkRule = lib.concatStringsSep ", ";
    in
    ''
      ${mkRule [
        ''ACTION=="add", SUBSYSTEM=="backlight"''
        ''RUN+="${lib.getExe' pkgs.coreutils "chgrp"} video $sys$devpath/brightness"''
        ''RUN+="${lib.getExe' pkgs.coreutils "chmod"} g+w $sys$devpath/brightness"''
      ]}
      # Ethernet expansion card support
      ${mkRule [
        ''ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0bda", ATTR{idProduct}=="8156"''
        ''ATTR{power/autosuspend}="20"''
      ]}
    '';
}
