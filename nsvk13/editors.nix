{ pkgs, ... }:

{
  home.packages = with pkgs; [
    vscode
  ];

  home.sessionVariables = {
    EDITOR = "code --wait";
    VISUAL = "code --wait";
  };
}
