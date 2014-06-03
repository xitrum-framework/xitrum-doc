#!/bin/sh

make_html() {
  cd $1

  rm -f conf.py
  cp ../conf.py .
  ln -s ../Makefile .
  make html

  cd ..
}
make clean
make_html en
make_html ja
