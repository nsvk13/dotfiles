# ASUS TUF Gaming A15 — AMD Ryzen (iGPU drives the internal panel) + RTX 4060 Laptop.
{ inputs, lib, pkgs, ... }:

let
  # Writes `early_stop` on every port of the hub whose syspath is $1.
  usbPortEarlyStop = pkgs.writeShellScript "usb-port-early-stop" ''
    for attr in "$1"/*-port*/early_stop; do
      [ -w "$attr" ] && echo y > "$attr"
    done
    exit 0
  '';
in

{
  imports = [
    ../../modules/nixos/hardware/amd.nix
    ../../modules/nixos/hardware/nvidia-prime.nix
    ../../modules/nixos/hardware/asus.nix
    inputs.driftwm.nixosModules.driftwm
  ]
  ++ lib.optional (builtins.pathExists ./hardware-configuration.nix) ./hardware-configuration.nix;

  assertions = [
    {
      assertion = builtins.pathExists ./hardware-configuration.nix;
      message = "hosts/tuf/hardware-configuration.nix is missing: run ./scripts/bootstrap.sh tuf on the laptop.";
    }
  ];

  # Dual boot with Windows, same as before.
  boot.loader = {
    grub = {
      enable = true;
      device = "nodev";
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # `lspci -D | grep -E 'VGA|3D'` prints HEX, these are DECIMAL.
  hardware.nvidia.prime = {
    amdgpuBusId = "PCI:5@0:0:0";
    nvidiaBusId = "PCI:1@0:0:0";
  };

  # Windows keeps the RTC in local time; match it so the clock doesn't jump when you
  # boot back and forth (dual boot via GRUB os-prober).
  time.hardwareClockInLocalTime = true;

  # A USB hub port holding a dead or half-seated device retries enumeration forever:
  # descriptor read fails (-32 EPIPE), addressing fails (-71 EPROTO), the hub power
  # cycles the port and starts over — hundreds of dmesg lines a minute. Here it is
  # port 1 of the Realtek RTS5411 hub (`usb 3-2.1: unable to enumerate USB device`).
  #
  # `early_stop` is the kernel's own answer: the port gives up after a few failed
  # attempts instead of looping. It is a per-port sysfs attribute that resets on every
  # boot, so it has to be re-applied — setting it by hand does not survive a reboot.
  #
  # Applied to every hub port rather than the one offender: the port path
  # (3-2:1.0/3-2-port1) encodes which physical socket the hub sits in and would
  # silently stop matching the moment the hub is moved. Healthy ports are unaffected —
  # early_stop only changes behaviour for a port already failing to enumerate.
  #
  # Matched on the hub's USB *interface* (DEVTYPE usb_interface, DRIVER hub): the port
  # devices themselves are absent from the udev database (this kernel registers no
  # usb-port subsystem), so they cannot be matched directly, but they are created
  # underneath the interface by the time the hub driver binds. `bind` covers the normal
  # path, `add` is a cheap belt-and-braces; the script is idempotent.
  #
  # NOTE: this silences the symptom, not the cause. Whatever is in that port is faulty
  # — pull it out or swap the cable for the real fix.
  services.udev.extraRules = ''
    ACTION=="add|bind", SUBSYSTEM=="usb", ENV{DEVTYPE}=="usb_interface", ENV{DRIVER}=="hub", RUN+="${usbPortEarlyStop} /sys$devpath"
  '';

  # driftwm — trackpad-first infinite-canvas Wayland compositor. The NixOS module
  # registers a "driftwm" session in SDDM; the iGPU that drives the panel renders it at
  # full refresh. Per-user config is in home-manager. Plasma stays the default session.
  programs.driftwm.enable = true;

  # Installed with 24.11 — never bump this, it is not "the NixOS version".
  system.stateVersion = "24.11";
}
