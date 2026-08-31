# startLaTeX

startLaTeX is a minimal LaTeX starter repository that includes a few example
documents to learn from or customize.

## Contents
- resume.tex   : Resume example.
- lamport.tex  : Tutorial-style notes inspired by Lamport’s LaTeX book.

### Quick start
1. Enter the development shell:
   `nix develop`
2. Build any document with latexmk (example: resume.tex):
   `latexmk -interaction=nonstopmode -pdf -lualatex resume.tex`
   (Add `-pvc` for continuous preview.)
3. Or build the default document via the flake:
   `nix build`
   The output is available at ./result/resume.pdf

