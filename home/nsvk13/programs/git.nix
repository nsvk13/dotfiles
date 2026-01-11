{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;
    userName = "nsvk13";
    userEmail = "nsvkdev@gmail.com";
    
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}