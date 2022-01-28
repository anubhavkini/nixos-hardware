{ config, lib, pkgs, ... }:

let
  cfg = config.hardware.nvidia.powerManagement;
in
{
  imports = [
    ../../../common/cpu/intel
    ../../../common/gpu/nvidia-disable.nix
    ../../../common/pc/laptop
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
}
