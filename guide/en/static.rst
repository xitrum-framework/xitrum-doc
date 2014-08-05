Static files
============

Serve static files on disk
--------------------------

Project directory layout:

::

  config
  public
    favicon.ico
    robots.txt
    404.html
    500.html
    img
      myimage.png
    css
      mystyle.css
    js
      myscript.js
  src
  build.sbt

Xitrum automatically serves static files inside ``public`` directory.
URLs to them are in the form:

::

  /img/myimage.png
  /css/mystyle.css
  /css/mystyle.min.css

To refer to them:

::

  <img src={publicUrl("img/myimage.png")} />

To serve normal file in development environment and its minimized version in
production environment (mystyle.css and mystyle.min.css as above):

::

  <img src={publicUrl("css", "mystyle.css", "mystyle.min.css")} />

To send a static file on disk from your action, use ``respondFile``.

::

  respondFile("/absolute/path")
  respondFile("path/relative/to/the/current/working/directory")

To optimize static file serving speed,
you can avoid unnecessary file existence check with regex filter.
If request url does not match pathRegex, Xitrum will respond 404 for that request.

See ``pathRegex`` in ``config/xitrum.conf``.

index.html fallback
-------------------

If there's no route (no action) for URL ``/foo/bar`` (or ``/foo/bar/``),
Xitrum will try to look for static file ``public/foo/bar/index.html``
(in the "public" directory). If the file exists, Xitrum will respond it
to the client.

404 and 500
-----------

404.html and 500.html in ``public`` directory are used when there's no matching
route and there's error processing request, respectively. If you want to use
your own error handler:

::

  import xitrum.Action
  import xitrum.annotation.{Error404, Error500}

  @Error404
  class My404ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Not Found") + ")")
      else
        renderInlineView("Not Found")
    }
  }

  @Error500
  class My500ErrorHandlerAction extends Action {
    def execute() {
      if (isAjax)
        jsRespond("alert(" + jsEscape("Internal Server Error") + ")")
      else
        renderInlineView("Internal Server Error")
    }
  }

Response status is set to 404 or 500 before the actions are executed, so you
don't have to set yourself.

Serve resource files in classpath with WebJars convention
---------------------------------------------------------

WebJars
~~~~~~~

`WebJars <http://www.webjars.org/>`_ provides a lot of web libraries that you can
declare as a dependency in your project.

For example, if you want to use `Underscore.js <http://underscorejs.org/>`_,
declare in your project's ``build.sbt`` like this:

::

  libraryDependencies += "org.webjars" % "underscorejs" % "1.6.0-3"

Then in your .jade template file:

::

  script(src={webJarsUrl("underscorejs/1.6.0", "underscore.js", "underscore-min.js")})

Xitrum will automatically use ``underscore.js`` for development environment and
``underscore-min.js`` for production environment.

The result will look like this:

::

  /webjars/underscorejs/1.6.0/underscore.js?XOKgP8_KIpqz9yUqZ1aVzw

If you want to use the same file for both environments:

::

  script(src={webJarsUrl("underscorejs/1.6.0/underscore.js")})

Save resource file inside .jar file with WebJars convention
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

If you are a library developer and want to serve myimage.png from your library,
which is a .jar file in classpath, save myimage.png in your .jar file with
`WebJars <http://www.webjars.org/>`_ convention, example:

::

  META-INF/resources/webjars/mylib/1.0/myimage.png

To serve it:

::

  <img src={webJarsUrl("mylib/1.0/myimage.png")} />

In both development and production environments, the URL will be:

::

  /webjars/mylib/1.0/myimage.png?xyz123

Respond a file in classpath
~~~~~~~~~~~~~~~~~~~~~~~~~~~

To respond a file inside an classpath element (a .jar file or a directory), even
when the file is not saved with `WebJars <http://www.webjars.org/>`_ convention:

::

  respondResource("path/relative/to/the/classpath/element")

Ex:

::

  respondResource("akka/actor/Actor.class")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore.js")
  respondResource("META-INF/resources/webjars/underscorejs/1.6.0/underscore-min.js")

Client side cache with ETag and max-age
---------------------------------------

Xitrum automatically adds `Etag <http://en.wikipedia.org/wiki/HTTP_ETag>`_ for
static files on disk and in classpath.

ETags for small files are MD5 of file content. They are cached for later use.
Keys of cache entries are ``(file path, modified time)``. Because modified time
on different servers may differ, each web server in a cluster has its own local
ETag cache.

For big files, only modified time is used as ETag. This is not perfect because not
identical file on different servers may have different ETag, but it is still better
than no ETag at all.

``publicUrl`` and ``webJarsUrl`` automatically add ETag to the URLs they
generate. For example:

::

  webJarsUrl("jquery/2.1.1/jquery.min.js")
  => /webjars/jquery/2.1.1/jquery.min.js?0CHJg71ucpG0OlzB-y6-mQ

Xitrum also sets ``max-age`` and ``Expires`` headers to
`one year <https://developers.google.com/speed/docs/best-practices/caching>`_.
Don't worry that browsers do not pickup a latest file when you change it.
Because when a file on disk changes, its ``modified time`` changes, thus the URLs
generated by ``publicUrl`` and ``webJarsUrl`` also change. Its ETag cache
is also updated because the cache key changes.

GZIP
----

Xitrum automatically gzips textual responses. It checks the ``Content-Type``
header to determine if a response is textual: ``text/html``, ``xml/application`` etc.

Xitrum always gzips static textual files, but for dynamic textual responses,
for overall performance reason it does not gzips response smaller than 1 KB.

Server side cache
-----------------

To avoid loading files from disk, Xitrum caches small static files
(not only textual) in memory with LRU (Least Recently Used) expiration.
See ``small_static_file_size_in_kb`` and ``max_cached_small_static_files``
in ``config/xitrum.conf``.
