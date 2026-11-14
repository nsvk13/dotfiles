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

  # Пейджер для git: подсветка синтаксиса внутри диффа и построчная подсветка
  # того, что реально изменилось в строке, а не «вся строка красная / вся
  # зелёная». Модулем, а не пакетом: он сам прописывает core.pager и
  # interactive.diffFilter в git-конфиг (programs.git.delta переименован в
  # programs.delta, старое имя даёт obsolete-warning).
  programs.delta = {
    enable = true;
    options = {
      # n/N прыгают между файлами диффа вместо построчной прокрутки.
      navigate = true;
      line-numbers = true;
      # side-by-side НЕ включаем: на 100 колонках две панели дают по ~45
      # символов, и любой YAML или терраформ начинает переноситься в кашу.
      # Включать точечно: git -c delta.side-by-side=true diff.
      side-by-side = false;
      # Из тем delta (--list-syntax-themes) Nord единственная из нашего рица.
      # Это тема ПОДСВЕТКИ КОДА, с темой терминала (Kanagawa) не конфликтует.
      syntax-theme = "Nord";
    };
  };
}
