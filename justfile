NOM := "nom --json"

rebuild:
    sudo nixos-rebuild switch --flake . --log-format internal-json |& {{NOM}}

clean:
    sudo nix-collect-garbage -d
