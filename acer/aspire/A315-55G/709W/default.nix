{ config, lib, pkgs, ... }:

{
  imports = [
    ../../../../common/cpu/intel
    ../../../../common/gpu/nvidia.nix
#   ../../../../common/gpu/nvidia-disable.nix
    ../../../../common/pc/laptop
    ../../../../common/pc/laptop/hdd
  ];

  boot.initrd.availableKernelModules = lib.mkDefault [
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];

  # Backlight keys.
  boot.kernelParams = [ "acpi_backlight=video" ];
  
  boot.kernelModules = lib.mkDefault [ "kvm-intel" ];

  hardware.nvidia.prime = {
    intelBusId = lib.mkDefault "PCI:0:2:0";
    nvidiaBusId = lib.mkDefault "PCI:2:0:0";
  };

  hardware.nvidia.powerManagement.enable = lib.mkDefault true;
  hardware.nvidia.powerManagement.finegrained = lib.mkDefault true;

  # Nvidia's systemd power management doesn't support suspend-then-hibernate
  systemd.services.nvidia-suspend-then-hibernate = {
    description = "NVIDIA system suspend-then-hibernate actions";
  	before = [ "systemd-suspend-then-hibernate.service" ];
  	requiredBy = [ "systemd-suspend-then-hibernate.service" ];
  	path = with pkgs; [ kbd ];
  	serviceConfig = {
  	  Type = "oneshot";
  	  ExecStart = "${config.hardware.nvidia.package.out}/bin/nvidia-sleep.sh suspend";
  	};
  };

  systemd.services.nvidia-resume = {
    after = [ "systemd-suspend-then-hibernate.service" ];
    requiredBy = [ "systemd-suspend-then-hibernate.service" ];
  };
}
