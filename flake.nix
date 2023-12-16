{
  description = "Get Started with LaTeX";
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
    flake-utils.url = github:numtide/flake-utils;
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-full latex-bin latexmk;
          };
        in
        rec {
          packages = {
            document = pkgs.stdenvNoCC.mkDerivation rec {
              name = "latex-document";
              src = self;
              buildInputs = [ pkgs.coreutils tex ];
              phases = [ "unpackPhase" "buildPhase" "installPhase" ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                mkdir -p .cache/texmf-var
                env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                  SOURCE_DATE_EPOCH=$(date +%s) \
                  OSFONTDIR=${pkgs.commit-mono}/share/fonts \
                  latexmk -interaction=nonstopmode -pdf -lualatex \
                  document.tex resume.tex;
              '';
              installPhase = ''
                mkdir -p $out
                cp document.pdf $out/
                cp resume.pdf $out/
                cp -r document $out/
              '';
            };
          };
          packages.default = packages.document;
          devShell = with pkgs; mkShell { packages = [ packages.document.buildInputs ]; shellHook = ''echo -n Hello LaTeX''; };
        });
}
