{
  description = "Get Started with LaTeX";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      # Define only Linux and macOS systems natively
      systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          
          # Size Optimization: Removed `scheme-full`. `texliveSmall` already provides a base environment.
          tex = pkgs.texliveSmall.withPackages (ps: with ps; [
            latex-bin latexmk lwarp enumitem titlesec
          ]);

          # Speed Optimization: Replaced the manual copy loop with `symlinkJoin`
          fonts = pkgs.symlinkJoin {
            name = "resume-fonts";
            paths = with pkgs; [
              inter montserrat commit-mono geist-font plus-jakarta-sans
              ibm-plex jetbrains-mono fira-code roboto lato
            ];
          };
        in
        {
          default = pkgs.stdenvNoCC.mkDerivation {
            name = "resume-document";
            src = self;
            buildInputs = [ pkgs.coreutils pkgs.poppler-utils tex fonts ];
            
            # Expose fonts so the devShell can access the same derivation
            passthru = { inherit fonts; };
            
            phases = [ "unpackPhase" "buildPhase" "installPhase" ];
            buildPhase = ''
              export PATH="${pkgs.lib.makeBinPath [ pkgs.coreutils pkgs.poppler-utils tex ]}";
              export OSFONTDIR="${fonts}/share/fonts";
              export TEXMFHOME="$(pwd)/.cache"
              export TEXMFVAR="$(pwd)/.cache/texmf-var"
              mkdir -p "$TEXMFVAR"
              
              luaotfload-tool --update
              latexmk -interaction=nonstopmode -pdf -lualatex resume.tex
            '';
            installPhase = ''
              mkdir -p $out
              cp resume.pdf $out/
            '';
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          document = self.packages.${system}.default;
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ document ];
            shellHook = ''
              export OSFONTDIR="${document.passthru.fonts}/share/fonts"
              export TEXMFHOME="$(pwd)/.cache"
              export TEXMFVAR="$(pwd)/.cache/texmf-var"
              mkdir -p "$TEXMFVAR"
              
              # Speed Optimization: Only run font DB refresh if the cache is actually missing
              if [ ! -f "$TEXMFVAR/luatex-cache/generic/names/luaotfload-names.luc" ]; then
                echo "Updating LuaLaTeX font cache in background..."
                luaotfload-tool --update -q &
              fi

              export SOURCE_DATE_EPOCH=$(date +%s);
              printf "\n\t%s\n\t%s\n\n" "Hello LaTeX" "run: latexmk -interaction=nonstopmode -pdf -pvc -lualatex resume.tex"
            '';
          };
        }
      );
    };
}
