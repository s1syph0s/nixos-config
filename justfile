NOM := "nom --json"

alias r := rebuild
alias c := clean

rebuild:
    @sudo echo # just to get sudo
    sudo nixos-rebuild switch --flake . --log-format internal-json |& {{NOM}}

clean:
    sudo nix-collect-garbage -d
