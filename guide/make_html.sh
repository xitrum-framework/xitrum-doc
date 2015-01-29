#!/bin/sh

make_html() {
  cd $1

  rm -f conf.py
  cp ../conf.py .
  ln -s ../Makefile .
  make html
  cp ../html_static/basic.css _build/html/_static/

  cd ..
}
make clean
make_html en
make_html ja
make_html ko
make_html ru
make_html vi
