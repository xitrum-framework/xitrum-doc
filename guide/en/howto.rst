HOWTO
=====

This chapter contains various small tips. Each tip is too small to have its own
chapter.

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

  case class MyConfig(username: String, password: String, children: Seq[String])
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

  import xitrum.util.SeriDeseri
  val bytes = SeriDeseri.toBytes("my serializable object")

To deserialize bytes back:

::

  val option = SeriDeseri.fromBytes[MyType](bytes)  // Option[MyType]

If you want to save to file:

::

  import xitrum.util.Loader
  Loader.bytesToFile(bytes, "myObject.bin")

To load from the file:

::

  val bytes = Loader.bytesFromFile("myObject.bin")

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
in `xitrum.js <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/js.scala>`_.

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

Temporary directory
-------------------

Xitrum projects by default (see ``tmpDir`` in xitrum.conf) uses ``tmp`` directory
in the current working directory to save Scalate generated .scala files, big
upload files etc.

To get path to that directory:

::

  xitrum.Config.xitrum.tmpDir.getAbsolutePath

To create a new file or directory in that directory:

::

  val file = new java.io.File(xitrum.Config.xitrum.tmpDir, "myfile")

  val dir = new java.io.File(xitrum.Config.xitrum.tmpDir, "mydir")
  dir.mkdirs()

Stream videos
-------------

There are many ways to stream videos. One easy way:

* Serve interleaved .mp4 video files, so that users can play the videos while
  downloading.
* And use a HTTP server like Xitrum that supports
  `range requests <http://en.wikipedia.org/wiki/Byte_serving>`_, so that users
  can skip to a movie position that has not been downloaded.

You can use `MP4Box <http://gpac.wp.mines-telecom.fr/mp4box/>`_ to interleave
movie file data by chunks of 500 milliseconds:

::

  MP4Box -inter 500 movie.mp4
