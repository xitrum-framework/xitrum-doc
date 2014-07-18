Netty handlers
==============

This chapter is advanced, you don't have to know to use Xitrum normally. To
understand, you must have knowlege about `Netty <http://netty.io/>`_.

`Rack <http://en.wikipedia.org/wiki/Rack_(Web_server_interface)>`_,
`WSGI <http://en.wikipedia.org/wiki/Web_Server_Gateway_Interface>`_, and
`PSGI <http://en.wikipedia.org/wiki/PSGI>`_ have middleware architecture.
Xitrum is based on `Netty <http://netty.io/>`_ which has the same thing called
handlers. You can create additional handlers and customize the channel pipeline
of handlers. Doing this, you can maximize server performance for your specific
use case.

This chaper describes:

* Netty handler architecture
* Handlers that Xitrum provides and their default order
* How to create and use custom handler

Netty handler architecture
--------------------------

For each connection, there is a channel pipeline to handle the IO data.
A channel pipeline is a series of handlers. There are 2 types of handlers:

* Inbound: the request direction client -> server
* Outbound: the response direction server -> client

Please see the doc of `ChannelPipeline <http://netty.io/4.0/api/io/netty/channel/ChannelPipeline.html>`_
for more information.

::

                                                 I/O Request
                                            via Channel or
                                        ChannelHandlerContext
                                                      |
  +---------------------------------------------------+---------------+
  |                           ChannelPipeline         |               |
  |                                                  \|/              |
  |    +---------------------+            +-----------+----------+    |
  |    | Inbound Handler  N  |            | Outbound Handler  1  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  |               |                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler N-1 |            | Outbound Handler  2  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  .               |
  |               .                                   .               |
  | ChannelHandlerContext.fireIN_EVT() ChannelHandlerContext.OUT_EVT()|
  |        [ method call]                       [method call]         |
  |               .                                   .               |
  |               .                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler  2  |            | Outbound Handler M-1 |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  |               |                                  \|/              |
  |    +----------+----------+            +-----------+----------+    |
  |    | Inbound Handler  1  |            | Outbound Handler  M  |    |
  |    +----------+----------+            +-----------+----------+    |
  |              /|\                                  |               |
  +---------------+-----------------------------------+---------------+
                  |                                  \|/
  +---------------+-----------------------------------+---------------+
  |               |                                   |               |
  |       [ Socket.read() ]                    [ Socket.write() ]     |
  |                                                                   |
  |  Netty Internal I/O Threads (Transport Implementation)            |
  +-------------------------------------------------------------------+

Custom handlers
---------------

When starting Xitrum server, you can pass in your own
`ChannelInitializer <http://netty.io/4.0/api/io/netty/channel/ChannelInitializer.html>`_:

::

  import xitrum.Server

  object Boot {
    def main(args: Array[String]) {
      Server.start(myChannelInitializer)
    }
  }

For HTTPS server, Xitrum will automatically prepend SSL handler to the pipeline.
You can reuse Xitrum handlers in your pipeline.

Xitrum default handlers
-----------------------

See `xitrum.handler.DefaultHttpChannelInitializer <https://github.com/xitrum-framework/xitrum/blob/master/src/main/scala/xitrum/handler/ChannelInitializer.scala>`_.

Sharable handlers (same instances are shared among many connections) are put in
``DefaultHttpChannelInitializer`` object above so that they can be easily picked
up by apps that want to use custom pipeline. Those apps may only want a subset
of default handlers.

For example, when an app uses its own dispatcher (not Xitrum's routing/dispatcher)
and only needs Xitrum's fast static file serving, it may use only these handlers:

Inbound:

* ``HttpRequestDecoder``
* ``PublicFileServer``
* Its own dispatcher

Outbound:

* ``HttpResponseEncoder``
* ``ChunkedWriteHandler``
* ``XSendFile``
