{ pkgs, lib }:
pkgs.stdenvNoCC.mkDerivation {
  name = "waydroid_script";
  format = "other";

  src = pkgs.fetchFromGitHub {
    owner = "casualsnek";
    repo = "waydroid_script";
    rev = "ddaa6b190f98b250e433c14946de7b69713a4b94";
    hash = "sha256-jTfjnylKknfwfcenHOL4GjGHUfr5U84gIPQjTZjNRE0=";
  };

  buildInputs = [
    (pkgs.python3.withPackages (ps: [
      ps.tqdm
      ps.requests
      ps.inquirerpy
    ]))
  ];

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  postPatch = ''
    patchShebangs main.py
  '';

  installPhase = /* sh */ ''
    mkdir -p $out/libexec
    cp -r . $out/libexec/waydroid_script
    mkdir -p $out/bin
    makeShellWrapper $out/libexec/waydroid_script/main.py $out/bin/waydroid_script \
      --prefix PATH : "${lib.makeBinPath [ pkgs.lzip ]}"
  '';
}
