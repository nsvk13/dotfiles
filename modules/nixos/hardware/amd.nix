# AMD Ryzen CPU + Radeon iGPU.
{ ... }:

{
  hardware.cpu.amd.updateMicrocode = true;
  # amdgpu in initrd: early KMS, no flicker or resolution jump during boot.
  hardware.amdgpu.initrd.enable = true;
  # amd_pstate=active (EPP) is already the kernel default on Zen 2+ — power-profiles-daemon drives it.
}
