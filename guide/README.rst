This Xitrum Guide is written using
`Sphinx Documentation Generator <http://en.wikipedia.org/wiki/Sphinx_%28documentation_generator%29>`_.

Install Sphinx 1.2+
-------------------

::

  easy_install -U Sphinx
  export LANG=en_US.UTF-8
  export LC_ALL=en_US.UTF-8

On Ubuntu, alternatively you can install package python-sphinx.

Generate HTML version
---------------------

::

  ./make_html

The generated HTML files will be put in ``<lang>/_build/html`` directory.

Generate PDF version
--------------------

On Mac, install `MacTex <http://tug.org/mactex/>`_.

On Ubuntu, install these packages:

* texlive-latex-recommended
* texlive-latex-extra
* texlive-fonts-recommended

Then:

::

  ./make_latexpdf

xitrum.pdf will be put in ``<lang>/_build/latex`` directory.

More info about generating PDF for Japanese language:
http://sphinx-users.jp/cookbook/pdf/latex.html

Update Xitrum Guide to Xitrum Homepage
--------------------------------------

`Xitrum Homepage <https://github.com/xitrum-framework/xitrum-framework.github.io>`_

Copy to ``guide`` directory. Also copy ``xitrum.pdf``.

Be careful not to delete ``guide/xitrum-pdf.png``.

Add to ``guide/index.html``:

::

  <p>
    <a href="xitrum.pdf" title="PDF" style="float:left"><img src="xitrum-pdf.png"/></a>
    <a href="xitrum.pdf" title="PDF">Download PDF</a></p>
  </p>
  <div style="clear:both"></div>
