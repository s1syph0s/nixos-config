{ lib, fetchFromGitHub, rustPlatform }:

rustPlatform.buildRustPackage rec {
  pname = "hypr-kblayout";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "s1syph0s";
    repo = pname;
    rev = "be04ba141ecbbaa2517455554e2badbebfadf517";
    hash = "sha256-hg/6JsEIM/CXYbQICPPluZqQZ+jvGRiwk6sVqg5b5t4=";
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
