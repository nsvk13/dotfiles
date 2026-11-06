# My NixOS Dotfiles 🚀

Flake-based NixOS + home-manager config.

## Hosts

| Host  | Machine                | GPU                          | Notes                          |
|-------|------------------------|------------------------------|--------------------------------|
| `tuf` | ASUS TUF Gaming A15     | Radeon 680M iGPU + RTX 4060  | ASUS ROG stack, driftwm, dual-boot |
| `m7`  | Ninkear M7             | AMD iGPU                     | plain desktop                  |

Host name == flake attribute == `networking.hostName`, so `nh os switch` picks the
right config automatically.

## Day-to-day

```sh
rebuild        # nh os switch               (apply current config)
update         # nh os switch --update      (bump inputs, then apply)
```

First time on a fresh install: `./scripts/bootstrap.sh tuf` (or `m7`) copies in
`hardware-configuration.nix`, sanity-checks the PRIME bus IDs and switches.

## ASUS laptop (tuf) — the asus-linux.org stack

Integration of <https://asus-linux.org/> for the TUF A15, in `modules/nixos/hardware/asus.nix`:

- **asusd / asusctl** (`services.asusd.enable`) — keyboard backlight & aura, fan curves,
  performance profiles, battery charge limit, panel overdrive. Ships the `asusctl` CLI
  and the `rog-control-center` GUI.
- **No power-profiles-daemon / TLP** — asusctl 6.3.7 drives the kernel `platform_profile`
  and CPU EPP itself, so running PPD or TLP alongside fights it. Switch profiles with
  `asusctl profile` or ROG Control Center. (Want KDE's tray power slider back? Keep PPD
  and disable asusd's profile switching in `services.asusd.asusdConfig` — see `asus.nix`.)
- **ROG Control Center** autostarts in the session (tray + desktop notifications).

asusctl's CLI was reshuffled across the 6.x line (short flags like `-c`/`-P` became
nested subcommands such as `battery limit` / `profile set`). Check the exact syntax for
the installed version with `asusctl --help` and `asusctl <subcommand> --help`. The
subcommands you'll use: `profile` (Quiet/Balanced/Performance), `aura` or `leds`
(keyboard lighting), `battery` (charge limit).

**Battery charge limit** is left at 100% by choice. To cap it for longevity, set it once
via `asusctl` — it persists in asusd across reboots (e.g. `asusctl battery limit 80`, or
the older `asusctl -c 80`; see `--help`).

### Graphics: iGPU-primary + NVIDIA offload (kept on purpose)

The internal panel is wired to the **AMD iGPU**, which renders the desktop (incl. driftwm)
at full 165 Hz — it is far more than enough for 2D Wayland compositing. The **RTX 4060**
sleeps in D3cold when idle (`powerManagement.finegrained`) and wakes only for what you
offload:

```sh
nvidia-offload <app>     # run <app> on the dGPU (games, Blender, CUDA tools, …)
```

CUDA/ML workloads see the full 4060 this way while the desktop stays cool and quiet.
Making NVIDIA the primary renderer (`prime.sync`) would keep the dGPU powered 24/7 (more
heat, far shorter battery, rougher Wayland) with **no** smoothness gain for desktop work,
so we don't. Set the panel to 165 Hz in Plasma's display settings or driftwm's `[outputs]`.

### supergfxctl — intentionally NOT installed

Upstream deprecated it. RTD3 offload already powers the dGPU down. Only add
`services.supergfxd.enable` if you need VFIO GPU passthrough to a VM.

## driftwm (tuf only)

[driftwm](https://github.com/malbiruk/driftwm) — trackpad-first infinite-canvas Wayland
compositor — is added as a flake input; its NixOS module registers a **driftwm** session
in SDDM. Plasma stays the default/fallback session.

- Per-user config: `home/nsvk13/home.nix` → `wayland.windowManager.driftwm.settings`
  (writes `~/.config/driftwm/config.toml`, validated with `--check-config` at build).
- Default keybinds work out of the box: `mod+Return` → kitty, `mod+d` → fuzzel,
  Print → screenshot, brightness/volume/media keys, `mod+l` → swaylock. The helper tools
  those binds call are installed alongside.
- Extend from `config.reference.toml` in the driftwm repo.

> driftwm is experimental ("primarily built with AI"). Test it before daily-driving:
> pick **driftwm** at the SDDM session menu, or run `driftwm` from a TTY. Plasma remains
> the safe default, so a bad config can never lock you out.

## ASUS troubleshooting (apply only if you hit the symptom)

Notes distilled from asus-linux.org that are **not** auto-applied, because applying them
blind can break hardware that already works:

- **Silent internal speakers** → the Cirrus `cs35l41` amp quirk may be needed. See
  <https://asus-linux.org/guides/cirrus-amps/>.
- **Battery drains in sleep** → the laptop may default to s2idle. If the firmware offers
  S3, add `boot.kernelParams = [ "mem_sleep_default=deep" ];`. Do **not** force it if S3
  is unsupported — suspend will break.
- **Dual boot clock drift / charge limit ignored after Windows** → disable Windows
  "Fast Startup". (`time.hardwareClockInLocalTime` is already set for the clock.)
- **Second NVMe blocks suspend** → see
  <https://asus-linux.org/faq/general/secondary-nvme-suspend-issues/>.
- **AMD iGPU extra battery saving (unplugged)** → `powerprofilesctl configure-action
  amdgpu_dpm --enable` (and `amdgpu_panel_power`). NB: this needs power-profiles-daemon,
  which we do **not** run (asusd owns profiles) — only relevant if you switch to the
  keep-PPD setup described in `asus.nix`.
