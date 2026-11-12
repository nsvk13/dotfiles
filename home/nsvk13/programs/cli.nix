# Утилиты общего назначения. Отдельно от devops.nix: там инструменты работы
# (kubectl, helm, terraform), здесь — повседневный инструментарий и красоты.
#
# Где есть модуль home-manager — используется он, а не голый пакет: модуль
# настраивает конфиг и интеграцию с шеллом декларативно.
{ pkgs, ... }:

{
  # TUI-файловый менеджер. Превью картинок прямо в терминале — Ghostty
  # поддерживает kitty graphics protocol, так что это работает.
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    # Обёртка, которая меняет каталог шелла на тот, где вы вышли из yazi.
    # Задано явно: HM 26.05 сменил дефолт с "yy" на "y", но при
    # home.stateVersion < 26.05 (у нас 24.11) молча оставляет legacy и
    # предупреждает. Берём новое короткое имя.
    shellWrapperName = "y";
    settings.mgr = {
      show_hidden = false;
      sort_by = "natural";
      sort_dir_first = true;
    };
  };

  # Ctrl+R превращается в полноценный поиск по истории с фильтрами по каталогу
  # и хосту. Синхронизация в облако НЕ включается — история команд это
  # чувствительные данные, и отправлять их куда-либо нужно осознанно.
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      auto_sync = false;
      update_check = false;
      style = "compact";
      inline_height = 20;
      show_preview = true;
      # Ctrl+R ищет везде, стрелка вверх — только по текущему каталогу.
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  # Информация о системе с логотипом. Полезнее классического neofetch тем, что
  # написан на C и стартует мгновенно.
  programs.fastfetch = {
    enable = true;
    settings = {
      logo.type = "small";
      display.separator = "  ";
      modules = [
        "title"
        "separator"
        "os"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "de"
        "wm"
        "terminal"
        "cpu"
        "gpu"
        "memory"
        "swap"
        "disk"
        "break"
        "colors"
      ];
    };
  };

  # Универсальный fuzzy-выборщик: файлы, git-ветки, процессы, история — всё
  # через один интерфейс с превью.
  programs.television = {
    enable = true;
    enableZshIntegration = true;
  };

  # Мультиплексор. Нужен прежде всего НА СЕРВЕРАХ: сессия переживает обрыв SSH,
  # и долгий ansible-playbook или terraform apply не умирает вместе с
  # подключением. Локально вкладок Ghostty обычно достаточно.
  #
  # attachExistingSession намеренно false: иначе каждая новая вкладка Ghostty
  # цеплялась бы к той же сессии, что ломает смысл вкладок.
  programs.zellij = {
    enable = true;
    enableZshIntegration = false;
    attachExistingSession = false;
    settings = {
      theme = "nord";
      pane_frames = false;
    };
  };

  home.packages = with pkgs; [
    # Навигация и чтение
    glow # markdown в терминале с подсветкой

    # Система
    dust # du с деревом и гистограммой
    duf # df с человеческим выводом
    procs # ps с цветами и деревом процессов
    gping # ping графиком во времени
    bandwhich # кто сейчас ест трафик, по процессам

    # Шелл
    tldr # примеры использования вместо полного man
    hyperfine # честный бенчмарк команд со статистикой

    # Красоты
    cava # визуализатор звука, источник — PipeWire
    onefetch # статистика git-репозитория с логотипом языка
  ];
}
