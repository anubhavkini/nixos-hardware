{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.nvidia.powerManagement;
in
{
  imports = [
    ../../../common/cpu/intel
    ../../../common/gpu/nvidia.nix
    ../../../common/pc/laptop
    ../../../common/pc/laptop/hdd
  ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
    ];

    kernelModules = [ "kvm-intel" ];

    # Backlight keys.
    kernelParams = [ "acpi_backlight=video" ];
  };

  # TODO: OpenCL for intel and nvidia are not working
#  hardware.opengl.extraPackages = with pkgs; [
#    intel-compute-runtime
#  ];

  hardware.nvidia = {
    prime = {
      intelBusId = lib.mkDefault "PCI:0:2:0";
      nvidiaBusId = lib.mkDefault "PCI:2:0:0";
    };

    powerManagement = {
      enable = lib.mkDefault true;
      finegrained = lib.mkDefault true;
    };
  };

  # Nvidia's systemd power management doesn't support suspend-then-hibernate
  systemd.services.nvidia-suspend-then-hibernate = lib.mkIf cfg.enable {
    description = "NVIDIA system suspend-then-hibernate actions";
    before = [ "systemd-suspend-then-hibernate.service" ];
    requiredBy = [ "systemd-suspend-then-hibernate.service" ];
    path = with pkgs; [ kbd ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh suspend";
    };
  };

  systemd.services.nvidia-resume = lib.mkIf cfg.enable {
    after = [ "systemd-suspend-then-hibernate.service" ];
    requiredBy = [ "systemd-suspend-then-hibernate.service" ];
  };
}
