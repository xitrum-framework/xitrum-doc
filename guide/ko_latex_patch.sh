#!/bin/sh

# Called by Makefile
# Add package kotex to ko/_build/latex/xitrum.tex
TEX_FILE=$1
perl -pi -e 'if($.==7){s/\n/\n\\usepackage{kotex}\n/}' $TEX_FILE
