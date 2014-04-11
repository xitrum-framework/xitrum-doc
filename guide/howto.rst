HOWTO
=====

This chapter contains various small tips. Each tip is too small to have its own
chapter.

Link to an action
-----------------

Xitrum tries to be typesafe. Don't write URL manually. Do like this:

::

  <a href={url[ArticlesShow]("id" -> myArticle.id)}>{myArticle.title}</a>

Redirect to another action
--------------------------

Read to know `what redirection is <http://en.wikipedia.org/wiki/URL_redirection>`_.

::

  import xitrum.Action
  import xitrum.annotation.{GET, POST}

  @GET("login")
  class LoginInput extends Action {
    def execute() {...}
  }

  @POST("login")
  class DoLogin extends Action {
    def execute() {
      ...
      // After login success
      redirectTo[AdminIndex]()
    }
  }

  GET("admin")
  class AdminIndex extends Action {
    def execute() {
      ...
      // Check if the user has not logged in, redirect him to the login page
      redirectTo[LoginInput]()
    }
  }

You can also redirect to the current action with ``redirecToThis()``.

Forward to another action
-------------------------

Use ``forwardTo[AnotherAction]()``. While ``redirectTo`` above causes the browser to
make another request, ``forwardTo`` does not.

Determine is the request is Ajax request
----------------------------------------

Use ``isAjax``.

::

  // In an action
  val msg = "A message"
  if (isAjax)
    jsRender("alert(" + jsEscape(msg) + ")")
  else
    respondText(msg)

Manipulate collected routes
---------------------------

Xitrum automatically collect routes on startup.
If you want to manipulate the routes, you can use
`xitrum.Config.routes <http://ngocdaothanh.github.io/xitrum/api/index.html#xitrum.routing.RouteCollection>`_.

Example:

::

  import xitrum.{Config, Server}

  object Boot {
    def main(args: Array[String]) {
      // You can modify routes before starting the server
      val routes = Config.routes

      // Remove routes to an action by its class
      routes.removeByClass[MyClass]()

      if (demoVersion) {
        // Remove routes to actions by a prefix
        routes.removeByPrefix("/premium/features")

        // This also works
        routes.removeByPrefix("premium/features")
      }

      ...

      Server.start()
    }
  }

Basic authentication
--------------------

You can protect the whole site or just certain actions with
`basic authentication <http://en.wikipedia.org/wiki/Basic_access_authentication>`_.

Note that Xitrum does not support
`digest authentication <http://en.wikipedia.org/wiki/Digest_access_authentication>`_
because it provides a false sense of security. It is vulnerable to a man-in-the-middle attack.
For better security, you should use HTTPS, which Xitrum has built-in support
(no need for additional reverse proxy like Apache or Nginx just to add HTTPS support).

Config basic authentication for the whole site
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In config/xitrum.conf:

::

  "basicAuth": {
    "realm":    "xitrum",
    "username": "xitrum",
    "password": "xitrum"
  }

Add basic authentication to an action
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  import xitrum.Action

  class MyAction extends Action {
    beforeFilter {
      basicAuth("Realm") { (username, password) =>
        username == "username" && password == "password"
      }
    }
  }

Log
---

Use object xitrum.Log directly
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

From anywhere, you can call like this directly:

::

  xitrum.Log.debug("My debug msg")
  xitrum.Log.info("My info msg")
  ...

Use trait xitrum.Log
~~~~~~~~~~~~~~~~~~~~

If you want to have the information about where (which class) the log has been
made, you should extend trait xitrum.Log

::

  package my_package

  object MyModel extends xitrum.Log {
    xitrum.Log.debug("My debug msg")
    xitrum.Log.info("My info msg")
    ...
  }

In file log/xitrum.log you will see that the log messages comes from ``MyModel``.

Xitrum actions extend trait xitrum.Log, which provides ``log``.
In any action, you can do like this:

::

  log.debug("Hello World")

Config log level, log output file etc.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In build.sbt, there's this line:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.0.13"

This means that `Logback <http://logback.qos.ch/>`_ is used by default.
You may replace Logback with any implementation of SLF4J.

Logback config file is at ``config/logback.xml``.

Load config files
-----------------

JSON file
~~~~~~~~~

JSON is neat for config files that need nested structures.

Save your own config files in "config" directory. This directory is put into
classpath in development mode by build.sbt and in production mode by script/runner (and script/runner.bat).

myconfig.json:

::

  {
    "username": "God",
    "password": "Does God need a password?",
    "children": ["Adam", "Eva"]
  }

Load it:

::

  import xitrum.util.Loader

  case class MyConfig(username: String, password: String, children: List[String])
  val myConfig = Loader.jsonFromClasspath[MyConfig]("myconfig.json")

Notes:

* Keys and strings must be quoted with double quotes
* Currently, you cannot write comment in JSON file

Properties file
~~~~~~~~~~~~~~~

You can also use properties files, but you should use JSON whenever possible
because it's much better. Properties files are not typesafe, do not support UTF-8
and nested structures etc.

myconfig.properties:

::

  username = God
  password = Does God need a password?
  children = Adam, Eva

Load it:

::

  import xitrum.util.Loader

  // Here you get an instance of java.util.Properties
  val properties = Loader.propertiesFromClasspath("myconfig.properties")

Typesafe config file
~~~~~~~~~~~~~~~~~~~~

Xitrum also includes Akka, which includes the
`config library <https://github.com/typesafehub/config>`_ created by the
`company called Typesafe <http://typesafe.com/company>`_.
It may be a better way to load config files.

myconfig.conf:

::

  username = God
  password = Does God need a password?
  children = ["Adam", "Eva"]

Load it:

::

  import com.typesafe.config.{Config, ConfigFactory}

  val config   = ConfigFactory.load("myconfig.conf")
  val username = config.getString("username")
  val password = config.getString("password")
  val children = config.getStringList("children")

Serialize and deserialize
-------------------------

To serialize to ``Array[Byte]``:

::

  val bytes = SeriDeseri.toBytes("my serializable object")

To deserialize bytes back:

::

  val option = SeriDeseri.fromBytes[MyType](bytes)  // Option[MyType]

Encrypt data
------------

To encrypt data that you don't need to decrypt later (one way encryption),
you can use MD5 or something like that.

If you want to decrypt later, you can use the utility Xitrum provides:

::

  import xitrum.util.Secure

  // Array[Byte]
  val encrypted = Secure.encrypt("my data".getBytes)

  // Option[Array[Byte]]
  val decrypted = Secure.decrypt(encrypted)

You can use ``xitrum.util.UrlSafeBase64`` to encode and decode the binary data to
normal string (to embed to HTML for response etc.).

::

  // String that can be included in URL, cookie etc.
  val string = UrlSafeBase64.noPaddingEncode(encrypted)

  // Option[Array[Byte]]
  val encrypted2 = UrlSafeBase64.autoPaddingDecode(string)

If you can combine the above operations in one step:

::

  import xitrum.util.SeriDeseri

  val mySerializableObject = new MySerializableClass

  // String
  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject)

  // Option[MySerializableClass]
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted)

``SeriDeseri`` uses `Twitter Chill <https://github.com/twitter/chill>`_
to serialize and deserialize. Your data must be serializable.

You can specify a key for encryption.

::

  val encrypted = Secure.encrypt("my data".getBytes, "my key")
  val decrypted = Secure.decrypt(encrypted, "my key")

::

  val encrypted = SeriDeseri.toSecureUrlSafeBase64(mySerializableObject, "my key")
  val decrypted = SeriDeseri.fromSecureUrlSafeBase64[MySerializableClass](encrypted, "my key")

If no key is specified, ``secureKey`` in xitrum.conf file in config directory
will be used.

Multiple sites at the same domain name
--------------------------------------

If you want to use a reverse proxy like Nginx to run multiple different sites
at the same domain name:

::

  http://example.com/site1/...
  http://example.com/site2/...

You can config baseUrl in config/xitrum.conf.

In your JS code, to have the correct URLs for Ajax requests, use ``withBaseUrl``
in `xitrum.js <https://github.com/ngocdaothanh/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_.

::

  # If the current site's baseUrl is "site1", the result will be:
  # /site1/path/to/my/action
  xitrum.withBaseUrl('/path/to/my/action')

Convert Markdown text to HTML
-----------------------------

If you have already configured your project to use :doc:`Scalate template engine </template_engines>`,
you only have to do like this:

::

  import org.fusesource.scalamd.Markdown
  val html = Markdown("input")

Otherwise, you need to add this dependency to your project's build.sbt:

::

  libraryDependencies += "org.fusesource.scalamd" %% "scalamd" % "1.6"

Monitor file change
-------------------

You can register callback(s) for
`StandardWatchEventKinds <http://docs.oracle.com/javase/7/docs/api/java/nio/file/StandardWatchEventKinds.html>`_
on files or directories.

::

  import java.nio.file.Paths
  import xitrum.util.FileMonitor

  val target = Paths.get("absolute_path_or_path_relative_to_application_directory").toAbsolutePath
  FileMonitor.monitor(FileMonitor.MODIFY, target, { path =>
    // Do some callback with path
    println(s"File modified: $path")

    // And stop monitoring if necessary
    FileMonitor.unmonitor(FileMonitor.MODIFY, target)
  })

Under the hood, ``FileMonitor`` uses
`Schwatcher <https://github.com/lloydmeta/schwatcher>`_.
