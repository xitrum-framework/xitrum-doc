HOWTO
=====

This chapter contains various small tips. Each tip is too small to have its own
chapter.

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

Basic authentication
--------------------

Config basic authentication for the whole site
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In config/xitrum.conf:

::

  "basicAuth": {
    "realm":    "xitrum",
    "username": "xitrum",
    "password": "xitrum"
  }

Add basic authentication to a controller
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

::

  import xitrum.Controller

  class MyController extends Controller {
    beforeFilter {
      basicAuthenticate("Realm") { (username, password) =>
        username == "username" && password == "password"
      }
    }
  }

Link to an action
-----------------

Xitrum tries to be typesafe.

Don't write URL manually, use urlFor like this:

::

  <a href={Articles.show.url("id" -> myArticle.id)}>{myArticle.title}</a>

Log
---

Xitrum actions extend trait xitrum.Logger, which provides ``logger``.
In any action, you can do like this:

::

  logger.debug("Hello World")

Of course you can extend xitrum.Logger any time you want:

::

  object MyModel extends xitrum.Logger {
    ...
  }

In build.sbt, notice this line:

::

  libraryDependencies += "ch.qos.logback" % "logback-classic" % "1.0.9"

This means that `Logback <http://logback.qos.ch/>`_ is used by default.
Logback config file is at ``config/logback.xml``.
You may replace Logback with any implementation of SLF4J.

Load config files
-----------------

JSON file
~~~~~~~~~

JSON is neat for config files that need nested structures.

Save your own config files in "config" directory. This directory is put into
classpath in development mode by build.sbt and in production mode by bin/runner.sh.

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

Encrypt data
------------

To encrypt data that you don't need to decrypt later (one way encryption),
you can use MD5 or something like that.

If you want to decrypt later, you can use the utility Xitrum provides:

::

  import xitrum.util.Secure

  val encrypted: Array[Byte]         = Secure.encrypt("my data".getBytes)
  val decrypted: Option[Array[Byte]] = Secure.decrypt(encrypted)

You can use ``xitrum.util.UrlSafeBase64`` to encode and decode the binary data to
normal string (to embed to HTML for response etc.).

If you can combine the above operations in one step:

::

  import xitrum.util.SecureUrlSafeBase64

  val encrypted = SecureUrlSafeBase64.encrypt(mySerializableObject)  // A String
  val decrypted = SecureUrlSafeBase64.decrypt(encrypted).asInstanceOf[Option[mySerializableClass]]

``SecureUrlSafeBase64`` uses ``xitrum.util.SeriDeseri`` to serialize and deserialize.
Your data must be serializable.

You can specify a key for encryption:

::

  val encrypted = Secure.encrypt("my data".getBytes, "my key")
  val decrypted = Secure.decrypt(encrypted, "my key")

  val encrypted = SecureUrlSafeBase64.encrypt(mySerializableObject, "my key")
  val decrypted = SecureUrlSafeBase64.decrypt(encrypted, "my key").asInstanceOf[Option[mySerializableClass]]

If no key is specified, ``secureKey`` in xitrum.conf file in config directory
is used.

Create your own template engine
-------------------------------

The default template engine is Scalate.
If you want to create and use your own template engine:

1. Create a class that implements `xitrum.view.TemplateEngine <https://github.com/ngocdaothanh/xitrum/blob/master/src/main/scala/xitrum/view/TemplateEngine.scala>`_
2. Set that class in `xitrum.conf <https://github.com/ngocdaothanh/xitrum-new/blob/master/config/xitrum.conf#L47>`_
3. If your template engine needs config items, add them to xitrum.conf,
   then load them like this:

::

  import xitrum.Config
  val defaultType = Config.xitrum.config.getString("scalateDefaultType")

See project `Typesafe Config <https://github.com/typesafehub/config>`_ and
`its API <http://typesafehub.github.com/config/latest/api/com/typesafe/config/Config.html>`_.
