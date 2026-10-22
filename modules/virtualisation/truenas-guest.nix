{
  # Generic hardware profile for a NixOS VM on TrueNAS (QEMU/KVM, UEFI, virtio).
  # Stands in for a generated hardware-configuration.nix, so install with labelled partitions:
  #   mkfs.fat -F 32 -n boot /dev/vda1
  #   mkfs.ext4 -L nixos /dev/vda2
  flake.modules.nixos.truenas-guest =
    { lib, modulesPath, ... }:
    {
      imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

      boot.initrd.availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "virtio_scsi"
        "virtio_blk"
        "sr_mod"
      ];

      # Lets TrueNAS shut the VM down cleanly and report its IP.
      services.qemuGuest.enable = true;

      # Console on both the VNC/SPICE display and TrueNAS's serial shell.
      boot.kernelParams = [
        "console=tty0"
        "console=ttyS0,115200"
      ];

      fileSystems."/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/boot";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    };
}
