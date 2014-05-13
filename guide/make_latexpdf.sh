#!/bin/sh

make_latexpdf() {
  cd $1

  ln -s ../conf.py .
  ln -s ../Makefile .

  # latexpdf can't use .gif image
  sed -i.bak s/ajax_loading\.gif/ajax_loading\.png/g postback.rst
  make latexpdf
  mv postback.rst.bak postback.rst

  cd ..
}

make_latexpdf en
