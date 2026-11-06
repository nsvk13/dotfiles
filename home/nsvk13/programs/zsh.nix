{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    shellAliases = {
      ll = "eza -la";
      # Flake path and host come from programs.nh (NH_FLAKE + hostname).
      rebuild = "nh os switch";
      update = "nh os switch --update";
    };
  };

  programs.starship.enable = true;
  programs.fzf.enable = true;
  programs.zoxide.enable = true;
}
