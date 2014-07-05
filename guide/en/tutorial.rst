Tutorial
========

This chapter shortly describes how to create and run a Xitrum project.
**It assumes that you are using Linux and you have installed Java.**

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

Change to the newly created project directory and run ``sbt/sbt run``:

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run

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

Autoreload
----------

In development mode, Xitrum automatically reloads routes and classes in directory
`target/scala-2.11/classes`, so you don't need addional tool like
`JRebel <http://zeroturnaround.com/software/jrebel/>`_.

Xitrum uses the new classes to create new instances. Xitrum doesn't reload class
instances that have already been created, e.g. instances that are created and
kept in long running threads. This is sufficient for most cases.

When there's a change in directory `target/scala-2.11/classes`, Xitrum will
display log:

::

  [INFO] target/scala-2.11/classes changed; Reload classes and routes on next request

You can use SBT to continuously compile your project when there's change in your
project source code. Run in a console window other than the console window for
``sbt/sbt run`` above:

::

  sbt/sbt ~compile

You can also use Eclipse or IntelliJ to edit and compile your project.

Specify classes that shouldn't be reloaded
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Because Xitrum creates new a class loader each time it reloads classes, by default
all classes will be reloaded and all Scala objects will be reinitialized in the
new class loader. To avoid that, you may tell Xitrum to use the old ones in the
parent class loader (system class loader) of the new class loader.

There are cases you may want to do that. For example: Heavy classes that take
time to initialize or rarely modified during development.

Another example: Scala objects that contain actors with unique names. Reloading
the objects will cause them to be initialized again, thus cause
``akka.actor.InvalidActorNameException: actor name [name goes here] is not unique!``:

::

  package mypackage

  object WorkerPool {
    val numWorkers = Runtime.getRuntime.availableProcessors * 2
    val workers    = Seq.tabulate() { i =>
      val name = getClass.getName + "-" + i
      xitrum.Config.actorSystem.actorOf(Props[Worker], name)
    }
  }

To specify that the above shouldn't be reloaded:

::

  xitrum.DevClassLoader.ignorePattern = "mypackage\\.WorkerPool".r

If you want to disable the autoreload feature, set this before starting
Xitrum server:

::

  xitrum.Config.autoreloadInDevMode = false

Import the project to Eclipse
-----------------------------

You can `use Eclipse to write Scala code <http://scala-ide.org/>`_.

From the project directory, run:

::

  sbt/sbt eclipse

``.project`` file for Eclipse will be created from definitions in ``build.sbt``.
Now open Eclipse, and import the project.

Import the project to IntelliJ
------------------------------

You can also use `IntelliJ <http://www.jetbrains.com/idea/>`_, which also
has very good support for Scala.

To generate project files for IDEA, run:

::

  sbt/sbt gen-idea

Ignore files
------------

Create a new project as described at the :doc:`tutorial </tutorial>`.
These should be `ignored <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_:

::

  .*
  log
  project/project
  project/target
  routes.cache
  target
