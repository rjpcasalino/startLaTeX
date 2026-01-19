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
          # re: latexmk see: https://latex.us/support/latexmk/INSTALL
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive) scheme-full latex-bin latexmk lwarp;
          };
        in
        rec {
          packages = {
            document = pkgs.stdenvNoCC.mkDerivation rec {
              name = "latex-document";
              src = self;
              buildInputs = [ pkgs.coreutils tex pkgs.poppler_utils ];
              phases = [ "unpackPhase" "buildPhase" "installPhase" ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                mkdir -p .cache/texmf-var
                env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                  SOURCE_DATE_EPOCH=$(date +%s) \
                  OSFONTDIR=${pkgs.commit-mono}/share/fonts \
                  latexmk -interaction=nonstopmode -pdf -lualatex \
                  ABForm.tex resume.tex lamport.tex;
              '';
              installPhase = ''
                mkdir -p $out
                cp resume.pdf $out/
                cp ABForm.pdf $out/
                cp lamport.pdf $out
              '';
            };
          };
          packages.default = packages.document;
          devShell = with pkgs; mkShell { packages = [ packages.document.buildInputs ]; shellHook = ''SOURCE_DATE_EPOCH=$(date +%s); printf "\t%s\n\t%s\n", "Hello LaTeX", "run latexmk -interaction=nonstopmode -pdf -lualatex <your_tex_doc.tex>"''; };
        });
}
