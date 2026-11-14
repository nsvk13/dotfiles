# Редактор: VS Code.
#
# Пришёл на смену Zed (был в modules/nixos/applications.nix). Zed быстрый, но
# экосистема расширений у него пустая там, где нам нужно: Ansible, Terraform,
# Kubernetes.
#
# Почему не VSCodium, хотя он без телеметрии: в нём не работает Remote-SSH —
# расширение проприетарное, в open-vsx его нет и не будет. Прод у нас по ssh,
# так что это решающий аргумент. Телеметрия вместо этого выключена в
# vscode-settings.json.
#
# Почему `.fhs`, а не обычный пакет: расширения приносят с собой готовые
# динамически слинкованные бинарники (terraform-ls, ansible-lint, нодовый
# сервер Remote-SSH). На чистом NixOS они не стартуют — нет /lib64/ld-linux.
# FHS-обёртка даёт им привычное окружение, и расширения из маркетплейса просто
# работают, как на Ubuntu.
{ config, pkgs, ... }:

let
  # Пакет vscode 1.144.0 в nixos-26.05 не собирается — из-за этого в ноябре
  # установку системы пришлось разблокировать, заменив его на Zed (16f2925).
  # Падает postPatch, который выкидывает вендорный ripgrep ради системного:
  #
  #   rm: cannot remove 'resources/app/node_modules/@vscode/ripgrep/bin/rg'
  #
  # В 1.144.0 апстрим переехал — пакет стал @vscode/ripgrep-universal, уехал
  # в node_modules.asar.unpacked и получил подкаталог архитектуры. Путь в
  # nixpkgs остался старым. Чиним подменой пути в обеих строках фазы (rm и
  # следом ln -s на системный ripgrep), логику не трогаем.
  #
  # Собирать локально приходится потому, что VS Code несвободный и в
  # cache.nixos.org не попадает; из nix-community.cachix.org приезжает только
  # исходный tarball. Убрать, когда путь починят в nixpkgs: признак — сборка
  # проходит и без этого override.
  vscode-ripgrep-fixed = pkgs.vscode.overrideAttrs (old: {
    postPatch = builtins.replaceStrings
      [ "node_modules/@vscode/ripgrep/bin/rg" ]
      [ "node_modules.asar.unpacked/@vscode/ripgrep-universal/bin/linux-x64/rg" ]
      old.postPatch;
  });
in
{
  programs.vscode = {
    enable = true;
    package = vscode-ripgrep-fixed.fhs;

    # mutableExtensionsDir остаётся дефолтным (true): расширения ниже приходят
    # из nixpkgs, но доставить что-то руками из маркетплейса по-прежнему можно.
    #
    # userSettings здесь СОЗНАТЕЛЬНО не задаются — см. home.file ниже.
    profiles.default.extensions = with pkgs.vscode-extensions; [
      # Инфра — ради чего всё и затевалось
      redhat.ansible
      hashicorp.terraform
      ms-kubernetes-tools.vscode-kubernetes-tools
      ms-azuretools.vscode-docker
      redhat.vscode-yaml

      # Прод по ssh
      ms-vscode-remote.remote-ssh

      # Этот конфиг сам на nix — без LSP его править больно
      jnoortheen.nix-ide

      eamodio.gitlens
      # direnv уже включён в ./devops.nix; расширение подхватывает .envrc,
      # чтобы тулчейн проекта видел не только терминал, но и сам редактор.
      mkhl.direnv

      # Та же тема, что в Ghostty и Plasma (../desktop/nordic.nix).
      arcticicestudio.nord-visual-studio-code
    ];
  };

  # Настройки лежат рядом, обычным JSON, и симлинк ведёт В РЕПОЗИТОРИЙ, а не в
  # /nix/store. Если отдать их `programs.vscode.*.userSettings`, home-manager
  # положит симлинк на стор, а стор read-only — тогда любая правка из GUI
  # падает с `EROFS: read-only file system`, и спотыкаются сами расширения:
  # ansible и terraform пишут в settings.json без спроса.
  #
  # Так настройки остаются под git (видно диффом, что накрутилось мышью), но
  # редактор может писать в файл. Плата: nix-пути сюда не подставить, поэтому
  # nil и nixfmt лежат в PATH — см. home.packages ниже.
  home.file.".config/Code/User/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/Someone/dotfiles/home/nsvk13/programs/vscode-settings.json";

  home.packages = with pkgs; [
    nil # LSP для nix, его зовёт jnoortheen.nix-ide по имени
    nixfmt # тот же форматтер, что в formatter.x86_64-linux флейка
  ];
}
