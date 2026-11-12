# My NixOS Dotfiles 🚀

Flake-based NixOS + home-manager config.

## Hosts

| Host  | Machine                | GPU                          | Notes                          |
|-------|------------------------|------------------------------|--------------------------------|
| `tuf` | ASUS TUF Gaming A15     | Radeon 680M iGPU + RTX 4060  | ASUS ROG stack, discrete MUX, dual-boot |
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

### Graphics: discrete MUX, external monitor only

Two host-level switches in `hosts/tuf/default.nix` decide everything here, and both are
documented in full at the top of that file — read it before flipping either.

`muxDiscrete = true` routes the internal panel to the **RTX 4060** instead of the Radeon
680M, so both outputs hang off one card. Consequences, on purpose:

- PRIME offload is meaningless and is force-disabled, so there is **no** `nvidia-offload`
  command. Everything already renders on the dGPU.
- `powerManagement.finegrained` is force-disabled too — RTD3 would otherwise power down
  the GPU that is painting the screen.
- It costs battery: the 680M renders nothing and the 4060 can never sleep.

This was flipped for driftwm, which could only see one of the two outputs while they lived
on separate GPUs. driftwm has since been dropped; Plasma handles both GPUs by itself, so
Optimus (`muxDiscrete = false`, `asusctl armoury set gpu_mux_mode 1`) would work again and
would get the battery back. It stays discrete only because nobody asked to change it back.

`internalPanelOff = true` adds `video=eDP-1:d video=eDP-2:d` to the kernel command line,
killing the built-in panel outright. The external HDMI monitor is the only display, and it
runs at 165 Hz.

> **Read before taking this laptop anywhere.** With `internalPanelOff` on and no external
> monitor plugged in, the machine boots to no display at all. At the GRUB menu press `e`,
> delete the `video=…` words, Ctrl-X to boot once — or pick an older generation.

### supergfxctl — intentionally NOT installed

Upstream deprecated it, and in discrete MUX mode there is nothing for it to switch.
Only add `services.supergfxd.enable` if you need VFIO GPU passthrough to a VM.

## Desktop theming — Nordic / Minimal (plasma-manager)

KDE Plasma 6 is configured declaratively via
[plasma-manager](https://github.com/nix-community/plasma-manager), wired in as a
`home-manager.sharedModules` entry in `flake.nix`.

- Theme module: `home/nsvk13/desktop/nordic.nix`. Two local switches at the top:
  `enable` (the whole theme) and `manageGtk` (whether home-manager owns the GTK bridge).
- Assets live system-wide in `modules/nixos/desktop.nix` so SDDM sees them too:
  `nordic`, `papirus-icon-theme`, `bibata-cursors`, plus `inter` in `fonts.packages`.

What is set: Nordic colour scheme, `breeze-dark` Plasma style, Breeze widget style and
window decoration, Papirus-Dark icons, Bibata-Modern-Ice cursor, Inter 10 for the UI and
JetBrainsMono Nerd Font 10 for monospace.

`overrideConfig` is deliberately **false**. In that mode plasma-manager edits individual
keys in the existing rc files instead of replacing them, and deletes nothing — so
hand-made settings outside the module (keyboard shortcuts, the `us,ru` layout, Dolphin's
hidden menubar, the monitor layout in `kwinoutputconfig.json`) survive untouched. Setting
it to true would delete 38 config files on every generation.

Two things Nordic cannot provide on Plasma 6: its `plasma/desktoptheme` and
`plasma/look-and-feel` packages ship only `metadata.desktop`, the Plasma 5 format, while
Plasma 6 requires `metadata.json`. Hence the native `breeze-dark` Plasma style, which
inherits the system colour scheme and therefore still renders Nordic.

Changes apply on the next login, not on `switch` — plasma-manager runs through an
autostart script (`~/.local/share/plasma-manager/`).

Not managed yet: panels, desktop containments and the wallpaper. The `panels` module
unconditionally deletes `~/.config/plasma-org.kde.plasma.desktop-appletsrc`, taking the
desktop containments and every widget config with it, so it needs a deliberate migration
rather than a flag flip.

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
