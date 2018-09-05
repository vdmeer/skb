#!/bin/env bash

pdflatex biblatex
biber biblatex
pdflatex biblatex
pdflatex biblatex

pdflatex bibtex
bibtex bibtex
pdflatex bibtex
pdflatex bibtex

rm *.aux *.bbl *.bcf *.blg *.log *.out *.xml
