{ pkgs, ... };

{
    users.users.nsvk13 = {
        isNormalUser = true;
        description = "nsvk13";
        extraGroups = [ "wheel" "docker" ];
        shell = pkgs.zsh;
    };

    program.zsh.enable = true;

}{ pkgs, ... }:

{
  services.xserver.enable = true;

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
}