{ pkgs, ... };

{ 
    environment.systemPackages = with pkgs; [
        kubectl
        k9s
        helm
        terraform
        ansible
    ];
}