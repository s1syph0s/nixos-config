{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hypr-kblayout";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "s1syph0s";
    repo = pname;
    rev = "e4adcf32e08b8bc2c2436d5e0c313132f6f623a9";
    hash = "sha256-tCN6EOqRVeCr+KKAA78KtqIhfniumu7HZgFjkDsyBtw="; 
  };

  cargoHash = "sha256-GAJf+wL2IBMqqAKXJXqONJ0oY889LBuAJewQH04krO4=";

  doCheck = false;

  meta = {
    description = "A custom waybar module to get keyboard layout for hyprland.";
    homepage = "https://github.com/s1syph0s/hypr-kblayout";
    license = lib.licenses.unlicense;
    maintainers = [];
  };
}
