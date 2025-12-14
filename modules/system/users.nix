{ pkgs, ... }:

{
  users.users.nsvk13 = {
    isNormalUser = true;
    description = "nsvk13";
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
}
