#!/bin/sh

make_latexpdf() {
  cd $1

  rm -rf conf.py
  rm -rf Makefile
  ln -s ../conf.py .
  ln -s ../Makefile .

  # PDF can't use .gif image
  sed -i.bak s/ajax_loading\.gif/ajax_loading\.png/g postback.rst

  if [ $1 = 'ja' ]
  then
    make latexpdfja
  else
    make latexpdf
  fi

  # Restore postback.rst
  mv postback.rst.bak postback.rst

  cd ..
}

make_latexpdf en
make_latexpdf ja
#make_latexpdf ko
make_latexpdf ru
#make_latexpdf vi