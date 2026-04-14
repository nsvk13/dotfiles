{ pkgs, ... }:

{
  users.users.nsvk13 = {
    isNormalUser = true;
    description  = "nsvk13";
    extraGroups  = [ "networkmanager" "wheel" "docker" ];
    shell        = pkgs.zsh;
    packages     = [];
  };
}