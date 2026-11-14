{ user, ... }:

{
  # `docker compose` and `docker buildx` ship with the docker package itself.
  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
    };
    daemon.settings = {
      log-driver = "json-file";
      log-opts = {
        max-size = "10m";
        max-file = "3";
      };
    };
  };
  users.users.${user}.extraGroups = [
    "docker"
    # Захват трафика без root: модуль ставит dumpcap с CAP_NET_RAW и отдаёт его
    # только этой группе. Без неё termshark (home/nsvk13/programs/devops.nix)
    # умеет лишь читать готовые pcap, а live-захват отваливается по правам.
    "wireshark"
  ];

  # Дефолтный package здесь — wireshark-cli (dumpcap + tshark), GUI не тянется:
  # termshark сам рисует интерфейс в терминале.
  programs.wireshark.enable = true;

  # Prebuilt foreign binaries (VS Code server, LSPs, npm/bun native modules) just work.
  programs.nix-ld.enable = true;
}
