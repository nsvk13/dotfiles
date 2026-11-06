{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user = {
        name = "nsvk13";
        email = "nsvkdev@gmail.com";
      };
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };
}
