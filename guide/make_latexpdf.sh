#!/bin/sh

make_latexpdf() {
  cd en

  rm -f conf.py
  cp ../conf.py .
  ln -s ../Makefile .

  # latexpdf can't use .gif image
  sed -i.bak s/ajax_loading\.gif/ajax_loading\.png/g postback.rst

  make latexpdf
  mv postback.rst.bak postback.rst

  cd ..
}

make_latexpdfja() {
  cd ja

  rm -f conf.py
  cp ../conf.py .
  ln -s ../Makefile .

  # Set language from None (English) to Japanese
  sed -i.bak s/\#language=None/language=\'ja\'/g conf.py

  # Oshida-san is the main author of the Japanese version
  sed -i.bak s/Ngoc[[:space:]]Dao,[[:space:]]Takeharu[[:space:]]Oshida/押田　丈治、ダオ　ゴック/g conf.py

  # latexpdf can't use .gif image
  sed -i.bak s/ajax_loading\.gif/ajax_loading\.png/g postback.rst

  make latexpdfja
  mv postback.rst.bak postback.rst

  cd ..
}

make_latexpdf
make_latexpdfja
