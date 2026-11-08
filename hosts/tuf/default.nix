# ASUS TUF Gaming A15 — AMD Ryzen (iGPU drives the internal panel) + RTX 4060 Laptop.
{ inputs, lib, pkgs, ... }:

let
  # MUX mode, and it has to match the firmware or the machine black-screens.
  #
  # false — Optimus (gpu_mux_mode=1, the shipped default). The AMD 680M drives the
  #   internal panel, the dGPU idles until `nvidia-offload <app>` wakes it, and the
  #   HDMI port stays wired to the dGPU. Best battery life. Downside: the panel and
  #   HDMI live on different GPUs, so a compositor that only opens one DRM device
  #   sees one of them. driftwm is such a compositor — it logs
  #     GPU candidates: ["/dev/dri/card1", "/dev/dri/card0"] / Using GPU: card1
  #   and never enumerates HDMI-A-1. Upstream issue malbiruk/driftwm#91,
  #   "Add multi-GPU (PRIME) support for outputs on secondary GPUs", still open.
  #
  # true — Discrete. The MUX routes the internal panel to the dGPU as well, so both
  #   outputs hang off card0 and driftwm drives both. Costs battery: the 680M no
  #   longer renders anything and the 4060 can never power down.
  #
  # Flipping this alone does nothing — the firmware switch is a separate, persistent
  # setting. The order matters, because finegrained RTD3 would otherwise try to power
  # off the GPU painting your screen:
  #
  #   1. set muxDiscrete = true here
  #   2. sudo nixos-rebuild switch --flake /home/nsvk13/Someone/dotfiles#tuf
  #   3. asusctl armoury set gpu_mux_mode 0   (no root needed, it goes via asusd)
  #   4. reboot
  #
  # To go back, reverse it: gpu_mux_mode 1, set this false, rebuild, reboot. If a
  # reboot ever lands on a black panel, the TTYs still work — Ctrl+Alt+F2, log in,
  # `asusctl armoury set gpu_mux_mode 1`, reboot.
  muxDiscrete = true;

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

      # Three, not ten, and the ESP is why. /boot IS the Windows ESP — 196 MB, of
      # which EFI binaries, GRUB and its font already eat ~48 MB. install-grub.pl
      # ignores boot.loader.grub.copyKernels here and forces copying on, because
      # /boot and /nix/store sit on different disks (nvme0n1p1 vs nvme1n1p4):
      #
      #   if (stat($bootPath)->dev != stat("/nix/store")->dev) { $copyKernels = 1; }
      #
      # So every kept generation's kernel and initrd land on the ESP. This initrd is
      # ~64 MB and the bzImage ~15 MB, leaving room for roughly two distinct
      # kernel/initrd pairs in ~148 MB. At 10 the ESP filled and the switch died with
      # "No space left on device / Failed to install bootloader".
      #
      # Generations sharing a kernel+initrd share one copy, so 3 is usually 1-2 pairs.
      # If this bites again, the real fix is giving /boot its own home on the ext4
      # root and mounting the ESP at /boot/efi instead — then bootPath and the store
      # are on one device, copying stops entirely and the limit stops mattering.
      configurationLimit = 3;
    };
    efi.canTouchEfiVariables = true;
  };

  hardware.nvidia = lib.mkMerge [
    {
      # `lspci -D | grep -E 'VGA|3D'` prints HEX, these are DECIMAL.
      prime = {
        amdgpuBusId = "PCI:5@0:0:0";
        nvidiaBusId = "PCI:1@0:0:0";
      };
    }

    # In discrete mode PRIME offload is meaningless — there is nothing to offload
    # from, the dGPU is the only thing driving a display — and finegrained power
    # management is actively dangerous: it powers the dGPU down at idle, and that
    # dGPU is painting the panel. Both off.
    (lib.mkIf muxDiscrete {
      prime.offload.enable = lib.mkForce false;
      prime.offload.enableOffloadCmd = lib.mkForce false;
      powerManagement.finegrained = lib.mkForce false;
    })
  ];

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
  # registers a "driftwm" session in SDDM. Which GPU renders it follows muxDiscrete
  # above: the AMD 680M in Optimus mode, the RTX 4060 in discrete mode (which is the
  # whole point — it is what lets driftwm see the HDMI output at all). Per-user config
  # is in home-manager. Plasma stays the default session.
  programs.driftwm.enable = true;

  # Installed with 24.11 — never bump this, it is not "the NixOS version".
  system.stateVersion = "24.11";
}
