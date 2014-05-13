#!/bin/sh

make_html() {
  cd $1

  ln -s ../conf.py .
  ln -s ../Makefile .
  make html

  cd ..
}

make_html en
make_html ja
