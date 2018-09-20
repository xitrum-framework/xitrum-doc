Tutorial
========

This chapter shortly describes how to create and run a Xitrum project.
**It assumes that you are using Linux and you have installed Java 8.**

Create a new empty Xitrum project
---------------------------------

To create a new empty project, download
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_:

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Or:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

Run
---

The de facto stardard way of building Scala projects is using
`SBT <https://github.com/harrah/xsbt/wiki/Setup>`_. The newly created project
has already included SBT 0.13 in ``sbt`` directory. If you want to install
SBT yourself, see its `setup guide <https://github.com/harrah/xsbt/wiki/Setup>`_.

Change to the newly created project directory and run ``sbt/sbt fgRun``:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt fgRun

This command will download all :doc:`dependencies </deps>`, compile the project,
and run the class ``quickstart.Boot``, which starts the web server. In the console,
you will see all the routes:

::

  [INFO] Load routes.cache or recollect routes...
  [INFO] Normal routes:
  GET  /  quickstart.action.SiteIndex
  [INFO] SockJS routes:
  xitrum/metrics/channel  xitrum.metrics.XitrumMetricsChannel  websocket: true, cookie_needed: false
  [INFO] Error routes:
  404  quickstart.action.NotFoundError
  500  quickstart.action.ServerError
  [INFO] Xitrum routes:
  GET        /webjars/swagger-ui/2.0.17/index                            xitrum.routing.SwaggerUiVersioned
  GET        /xitrum/xitrum.js                                           xitrum.js
  GET        /xitrum/metrics/channel                                     xitrum.sockjs.Greeting
  GET        /xitrum/metrics/channel/:serverId/:sessionId/eventsource    xitrum.sockjs.EventSourceReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/htmlfile       xitrum.sockjs.HtmlFileReceive
  GET        /xitrum/metrics/channel/:serverId/:sessionId/jsonp          xitrum.sockjs.JsonPPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/jsonp_send     xitrum.sockjs.JsonPPollingSend
  WEBSOCKET  /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocket
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr            xitrum.sockjs.XhrPollingReceive
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_send       xitrum.sockjs.XhrSend
  POST       /xitrum/metrics/channel/:serverId/:sessionId/xhr_streaming  xitrum.sockjs.XhrStreamingReceive
  GET        /xitrum/metrics/channel/info                                xitrum.sockjs.InfoGET
  WEBSOCKET  /xitrum/metrics/channel/websocket                           xitrum.sockjs.RawWebSocket
  GET        /xitrum/metrics/viewer                                      xitrum.metrics.XitrumMetricsViewer
  GET        /xitrum/metrics/channel/:iframe                             xitrum.sockjs.Iframe
  GET        /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketGET
  POST       /xitrum/metrics/channel/:serverId/:sessionId/websocket      xitrum.sockjs.WebSocketPOST
  [INFO] HTTP server started on port 8000
  [INFO] HTTPS server started on port 4430
  [INFO] Xitrum started in development mode

On startup, all routes will be collected and output to log. It is very
convenient for you to have a list of routes if you want to write documentation
for 3rd parties about the RESTful APIs in your web application.

Open http://localhost:8000/ or https://localhost:4430/ in your browser. In the
console you will see request information:

::

  [INFO] GET quickstart.action.SiteIndex, 1 [ms]

Import the project to Eclipse
-----------------------------

You can `use Eclipse to write Scala code <http://scala-ide.org/>`_.

From the project directory, run:

::

  sbt/sbt eclipse

``.project`` file for Eclipse will be generated from definitions in ``build.sbt``.
Now open Eclipse, and import the project.

Import the project to IntelliJ
------------------------------

You can also use `IntelliJ <http://www.jetbrains.com/idea/>`_.

With its Scala plugin installed, simply open your SBT project,
you don't need to generate project files as with Eclipse.

Autoreload
----------

You can autoreload .class files (hot swap) without having to restart your
program. However, to avoid performance and stability problems, you should only
autoreload .class files while developing (development mode).

Run with IDEs
~~~~~~~~~~~~~

While developing, when you run project in advanced IDEs like Eclipse or IntelliJ,
by default the IDEs will automatically reload code for you.

Run with SBT
~~~~~~~~~~~~

When you run with SBT, you need to open 2 console windows:

* One to run ``sbt/sbt fgRun``. This will run the program and reload .class files
  when they are changed.
* One to run ``sbt/sbt ~compile``. Whenever you edit source code files, this
  will compile the source code to .class files.

In the sbt directory, there's `agent7.jar <https://github.com/xitrum-framework/agent7>`_.
It's in charge of reloading .class files in the current working directory (and its subdirectories).
If you see the ``sbt/sbt`` script, you'll see the option like ``-javaagent:agent7.jar``.

DCEVM
~~~~~

Normal JVM only allows only changing method bodies. You may use
`DCEVM <https://github.com/dcevm/dcevm>`_, which is an open source modification
of the Java HotSpot VM that allows unlimited redefinition of loaded classes.

You can install DCEVM in 2 ways:

* `Patch <https://github.com/dcevm/dcevm/releases>`_ your existing Java installation.
* Install a `prebuilt <http://dcevm.nentjes.com/>`_ version (easier).

If you choose to patch:

* You can enable DCEVM permanently.
* Or set it as an "alternative" JVM. In this case, to enable DCEVM, every time
  you run ``java`` command, you need to specify ``-XXaltjvm=dcevm`` option.
  For example, you need to add ``-XXaltjvm=dcevm`` option to the ``sbt/sbt`` script.

If you use IDEs like Eclipse or IntelliJ, you need to configure them to use DCEVM
(not the default JVM) to run your project.

If you use SBT, you need to configure the ``PATH`` environment variable so that
the ``java`` command is from DCEVM (not from the default JVM). You still need
the ``javaagent`` above, because although DCEVM supports advanced class changes,
it itself doesn't reload classes.

See `DCEVM - A JRebel free alternative <http://javainformed.blogspot.jp/2014/01/jrebel-free-alternative.html>`_
for more info.

Ignore files
------------

Normally, these file should be
`ignored <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_
(not commited to your SVN or Git repository):

::

  .*
  log
  project/project
  project/target
  target
  tmp
