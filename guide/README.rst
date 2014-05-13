This Xitrum Guide is written using Sphinx:
http://en.wikipedia.org/wiki/Sphinx_%28documentation_generator%29

Install Sphinx
--------------

::

  easy_install -U Sphinx
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8

On Ubuntu, alternatively you can install package python-sphinx.

Generate HTML version
---------------------

::

  cd en
  ./make_html

The generated HTML files will be put in en/_build/html directory.

Generate PDF version
--------------------

On Mac, install `MacTex <http://tug.org/mactex/>`_.

On Ubuntu, install packages texlive-latex-recommended, texlive-latex-extra, and
texlive-fonts-recommended.

::

  cd en
  ./make_latexpdf

xitrum.pdf will be put in en/_build/latex directory.
