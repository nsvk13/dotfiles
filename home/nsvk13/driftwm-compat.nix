# Compatibility shim for home-manager's services.way-displays module.
#
# way-displays declares defaults for every registered compositor with a blind map
# over the option tree (modules/services/way-displays.nix):
#
#   wayland.windowManager = lib.mapAttrs (_name: _: {
#     systemd.variables = lib.mkOptionDefault [ "XDG_VTNR" ];
#   }) options.wayland.windowManager;
#
# so it hands a `systemd.variables` *definition* to compositors that never declared
# that option. home-manager's own modules (sway, hyprland, river, wayfire, labwc) all
# declare it; driftwm's home module declares only `systemd.enable`. Upstream dropped
# `variables` while reviewing malbiruk/driftwm#288 — "systemd.variables is unused, so
# it can go too" — and it genuinely is unused: `driftwm-session` already runs
# `systemctl --user import-environment` plus `dbus-update-activation-environment --all`,
# so there is no per-variable knob left to expose.
#
# The module system rejects a definition for an undeclared option structurally, while
# merging, i.e. BEFORE way-displays' own `mkIf cfg.enable` guard is discharged. So
# merely having way-displays in the module set — which home-manager always does — is
# enough to break evaluation:
#
#   error: The option `home-manager.users.nsvk13.wayland.windowManager.driftwm
#          .systemd.variables' does not exist. Definition values:
#   - In `.../modules/services/way-displays.nix':
#       { _type = "if"; condition = false; ... }
#
# Note `condition = false`: we do not enable way-displays, and it still fails.
#
# The map is still unfiltered on home-manager master as of 2026-11-08, so there is no
# newer home-manager or driftwm pin to move to — declaring the option here is the fix.
# It is inert by design, nothing reads it. Delete this file once home-manager filters
# that map to compositors that declare the option (or once driftwm declares it again).
{ lib, ... }:

{
  options.wayland.windowManager.driftwm.systemd.variables = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    visible = false;
    description = ''
      Inert compatibility stub — see the comment at the top of this file.
      driftwm imports the whole login environment into systemd and D-Bus from
      {command}`driftwm-session`, so setting this has no effect.
    '';
  };
}
