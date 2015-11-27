#!/bin/bash
echo "pdflatex"
makeindex rosbook_jp
pdflatex -interaction=nonstopmode rosbook_jp
