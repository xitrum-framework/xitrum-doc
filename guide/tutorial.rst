Tutorial
========

This chapter describes how to create and run a Xitrum project.
**It assumes that you are using Linux and you have installed Java.**

Create a new empty Xitrum project
---------------------------------

To create a new empty project, download
`xitrum-new.zip <http://cloud.github.com/downloads/ngocdaothanh/xitrum-new/xitrum-new.zip>`_:

::

  wget http://cloud.github.com/downloads/ngocdaothanh/xitrum-new/xitrum-new.zip

Or:

::

  curl -O http://cloud.github.com/downloads/ngocdaothanh/xitrum-new/xitrum-new.zip

Run
---

The de facto stardard way of building Scala projects is using
`SBT <https://github.com/harrah/xsbt/wiki/Setup>`_. The newly created project
has already included SBT 0.11.3-2 in ``sbt`` directory. If you want to install
SBT yourself, see its `setup guide <https://github.com/harrah/xsbt/wiki/Setup>`_.

Change to the newly created project directory and run ``sbt/sbt run``:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run

This command will download all :doc:`dependencies </deps>`, compile the project,
and run the class ``quickstart.Boot``, which starts the web server. In the console,
you will see all the routes:

::

  [INFO] Routes:
  GET   /                       quickstart.controller.Site#index
  POST  /xiturm/comet/:channel  xitrum.comet.CometController#publish

  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

On startup, all routes will be collected and output to log. It is very
convenient for you to have a list of routes if you want to write documentation
for 3rd parties about the RESTful APIs in your web application.

Open http://localhost:8000/ or https://localhost:4430/ in your browser. In the
console you will see request information:

::

  [DEBUG] GET quickstart.controller.Site#index, 1 [ms]
