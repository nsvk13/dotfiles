{ ... }:

{
  programs.git = {
    enable = true;

    userName = "nsvk13";
    userEmail = "nsvk13@users.noreply.github.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      core.editor = "code --wait";
    };
  };
}
