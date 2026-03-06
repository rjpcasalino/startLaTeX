StartLaTeX
==========

StartLaTeX is a minimal LaTeX starter repository that includes a few example
documents to learn from or customize.

Contents
--------
- resume.tex   : Resume template example.
- lamport.tex  : Tutorial-style notes inspired by Lamport’s LaTeX book.
- redhen.tex   : Fiction short story example.
- linux_rocks.png, rjpc.png : Sample images for experimenting with
  \includegraphics.
- flake.nix/flake.lock : Nix flake for a reproducible LaTeX environment and
  a default build that renders resume.pdf.

Quick start (Nix)
-----------------
1. Enter the development shell:
   nix develop
2. Build any document with latexmk (example: resume.tex):
   latexmk -interaction=nonstopmode -pdf -lualatex resume.tex
   (Use -pvc for continuous preview.)
3. Or build the default document via the flake:
   nix build
   The output is available at ./result/resume.pdf

Quick start (non-Nix)
---------------------
Install a LaTeX distribution that includes latexmk and LuaLaTeX (for example,
TeX Live), then run:
  latexmk -interaction=nonstopmode -pdf -lualatex resume.tex

Tips
----
- All .tex files live in the repository root.
- To build a different document, swap resume.tex with lamport.tex or
  redhen.tex in the commands above.
