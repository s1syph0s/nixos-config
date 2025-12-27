NOM := "nom --json"

rebuild:
    @sudo echo # just to get sudo
    nixos-rebuild switch --flake . --log-format internal-json -v |& {{NOM}}

clean:
    sudo nix-collect-garbage -d
