{
  description = "Get Started with LaTeX";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    with flake-utils.lib; eachSystem allSystems
      (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tex = pkgs.texliveSmall.withPackages (
            ps: with ps; [
              scheme-full latex-bin latexmk lwarp
            ]
          );
          # Aggregate modern typefaces into a single directory
          fonts = pkgs.runCommand "resume-fonts" {} ''
            mkdir -p $out/share/fonts
            for d in \
              ${pkgs.inter}/share/fonts \
              ${pkgs.montserrat}/share/fonts \
              ${pkgs.commit-mono}/share/fonts \
              ${pkgs.geist-font}/share/fonts \
              ${pkgs.plus-jakarta-sans}/share/fonts \
              ${pkgs.ibm-plex}/share/fonts \
              ${pkgs.jetbrains-mono}/share/fonts \
              ${pkgs.fira-code}/share/fonts \
              ${pkgs.roboto}/share/fonts \
              ${pkgs.lato}/share/fonts; do
              if [ -d "$d" ]; then
                find "$d" -type f \( -name '*.ttf' -o -name '*.otf' -o -name '*.ttc' \) \
                  -exec cp -f {} $out/share/fonts \;
              fi
            done
          '';
        in
        rec {
          packages = {
            document = pkgs.stdenvNoCC.mkDerivation rec {
              name = "resume-document";
              src = self;
              buildInputs = [ pkgs.coreutils pkgs.poppler-utils tex fonts ];
              phases = [ "unpackPhase" "buildPhase" "installPhase" ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                export OSFONTDIR="${fonts}/share/fonts";
                export TEXMFHOME="$(pwd)/.cache"
                export TEXMFVAR="$(pwd)/.cache/texmf-var"
                mkdir -p "$TEXMFVAR"
                # Force font cache update during Nix build
                luaotfload-tool --update --force
                latexmk -interaction=nonstopmode -pdf -lualatex resume.tex
                '';
              installPhase = ''
                mkdir -p $out
                cp resume.pdf $out/
              '';
            };
          };
          packages.default = packages.document;
          devShell = with pkgs; mkShell {
            # https://discourse.nixos.org/t/help-with-nix-shell-uses-a-nested-list-in-attribute-buildinputs/77810/8
            inputsFrom = [ packages.document ];
            shellHook = ''
              # Expose the Nix fonts to LuaLaTeX in the local shell
              export OSFONTDIR="${fonts}/share/fonts"
              # Isolate the TeX cache to the local project directory
              export TEXMFHOME="$(pwd)/.cache"
              export TEXMFVAR="$(pwd)/.cache/texmf-var"
              mkdir -p "$TEXMFVAR"
              # Force the font database to refresh when entering the shell
              echo "Updating LuaLaTeX font cache..."
              luaotfload-tool --update
              export SOURCE_DATE_EPOCH=$(date +%s);
              printf "\n\t%s\n\t%s\n\n" "Hello LaTeX" "run: latexmk -interaction=nonstopmode -pdf -pvc -lualatex resume.tex"
            '';
          };
        });
}
