{ lib, ... }:

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

  # Промпт в той же палитре Nord, что и тема Plasma. Раньше starship был
  # включён вообще без настроек и работал на дефолтном пресете.
  #
  # Символы требуют Nerd Font — он есть (nerd-fonts.jetbrains-mono в
  # modules/nixos/desktop.nix) и задан шрифтом терминала.
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;
      format = lib.concatStrings [
        "[╭─](nord3)"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$cmd_duration"
        "$line_break"
        "[╰─](nord3)$character"
      ];

      palette = "nord";
      palettes.nord = {
        nord3 = "#4C566A"; # приглушённый серо-синий — рамка и второстепенное
        nord8 = "#88C0D0"; # голубой — путь
        nord9 = "#81A1C1"; # синий — nix-shell
        nord11 = "#BF616A"; # красный — ошибка
        nord13 = "#EBCB8B"; # жёлтый — грязное дерево git
        nord14 = "#A3BE8C"; # зелёный — ветка и успех
        nord15 = "#B48EAD"; # сиреневый — длительность
      };

      directory = {
        style = "bold nord8";
        truncation_length = 3;
        truncate_to_repo = false;
        format = "[ $path]($style)[$read_only]($read_only_style) ";
        read_only = " ";
        read_only_style = "nord11";
      };

      git_branch = {
        style = "nord14";
        symbol = " ";
        format = "[$symbol$branch]($style) ";
      };

      git_status = {
        style = "nord13";
        format = "[$all_status$ahead_behind]($style) ";
        conflicted = "= ";
        ahead = "⇡\${count} ";
        behind = "⇣\${count} ";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count} ";
        untracked = "? ";
        stashed = " ";
        modified = "±\${count} ";
        staged = "+\${count} ";
        renamed = "» ";
        deleted = "✘\${count} ";
      };

      # Видно, что вы внутри nix develop / nix-shell, а не в обычном окружении.
      nix_shell = {
        style = "nord9";
        symbol = " ";
        format = "[$symbol$state]($style) ";
        impure_msg = "impure";
        pure_msg = "pure";
      };

      # Показывает время только у команд дольше двух секунд.
      cmd_duration = {
        style = "nord15";
        min_time = 2000;
        format = "[ $duration]($style) ";
      };

      character = {
        success_symbol = "[❯](bold nord14)";
        error_symbol = "[❯](bold nord11)";
        vimcmd_symbol = "[❮](bold nord8)";
      };
    };
  };

  programs.fzf.enable = true;
  programs.zoxide.enable = true;
}
