Async response
==============

List of responding methods:

* ``respondView``: responds HTML with or without layout
* ``respondInlineView``
* ``respondText("hello")``: responds a string without layout
* ``respondHtml("<html>...</html>")``: same as above, with content type set to "text/html"
* ``respondJson(List(1, 2, 3))``: converts Scala object to JSON object then responds
* ``respondJs("myFunction([1, 2, 3])")``
* ``respondJsonP(List(1, 2, 3), "myFunction")``: combination of the above two
* ``respondJsonText("[1, 2, 3]")``
* ``respondJsonPText("[1, 2, 3]", "myFunction")``
* ``respondBinary``: responds an array of bytes
* ``respondFile``: sends a file directly from disk, very fast
  because `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_
  (aka send-file) is used
* ``respondWebSocket("text")``: responds a WebSocket text frame
* ``respondEventSource("data", "event")``

Xitrum does not automatically send any default response.
You must explicitly call respondXXX methods above to send response.
If you don't call respondXXX, Xitrum will keep the HTTP connection for you,
and you can call respondXXX later.

To check if the connection is still open, call ``channel.isOpen``.
You can also use ``addConnectionClosedListener``:

::

  addConnectionClosedListener {
    // The connection has been closed
    // Unsubscribe from events, release resources etc.
  }

Because of the async nature, the response is not sent right away.
respondXXX returns
`ChannelFuture <http://static.netty.io/3.5/api/org/jboss/netty/channel/ChannelFuture.html>`_.
You can use it to perform actions when the response has actually been sent.

For example, if you want to close the connection after the response has been sent:

::

  val future = respondText("Hello")
  future.addListener(new ChannelFutureListener {
    def operationComplete(future: ChannelFuture) {
      future.getChannel.close()
    }
  })

Or shorter:

::

  respondText("Hello").addListener(ChannelFutureListener.CLOSE)

WebSocket
---------

::

  import xitrum.Controller

  class HelloWebSocket extends Controller {
    def echo = WEBSOCKET("echo") {
      // If you don't want to accept the connection, call channel.close()
      acceptWebSocket(new WebSocketHandler {
        def onOpen() {
          logger.debug("onOpen")
        }

        def onMessage(message: String) {
          // Send back data to the WebSocket client
          respondWebSocket(message.toUpperCase)
        }

        def onClose() {
          logger.debug("onClose")
        }
      })
    }
  }

To get URL to the above WebSocket action:

::

  object HelloWebSocket extends HelloWebSocket

  // Probably you want to use this in Scalate view etc.
  val url = HelloWebSocket.echo.webSocketAbsoluteUrl

SockJS
------

`SockJS <https://github.com/sockjs/sockjs-client>`_ is a browser JavaScript
library that provides a WebSocket-like object.
SockJS tries to use WebSocket first. If that fails it can use a variety
of ways but still presents them through the WebSocket-like object.

If you want to work with WebSocket API on all kind of browsers, you should use
SockJS and avoid using WebSocket directly.

::

  <script>
    var sock = new SockJS('http://mydomain.com/path_prefix');
    sock.onopen = function() {
      console.log('open');
    };
    sock.onmessage = function(e) {
      console.log('message', e.data);
    };
    sock.onclose = function() {
      console.log('close');
    };
  </script>

Xitrum includes the JavaScript file of SockJS.
In your view template, just write like this:

::

  ...
  html
    head
      != jsDefaults
  ...

SockJS does require a `server counterpart <https://github.com/sockjs/sockjs-protocol>`_.
Xitrum automatically does it for you.

::

  import xitrum.{Controller, SockJsHandler}
  import xitrum.handler.Server
  import xitrum.routing.Routes

  class EchoSockJsHandler extends SockJsHandler {
    // controller: the controller just before switching to this SockJS handler,
    // you can use extract session data, request headers etc. from it
    def onOpen(controller: Controller) {}

    def onMessage(message: String) {
      // Send back data to the SockJS client
      send(message)
    }

    def onClose() {}
  }

  object Boot {
    def main(args: Array[String]) {
      Routes.sockJs(classOf[EchoSockJsHandler], "echo")
      Server.start()
    }
  }

See `Various issues and design considerations <https://github.com/sockjs/sockjs-node#various-issues-and-design-considerations>`_:

::

  Basically cookies are not suited for SockJS model. If you want to authorize a
  session, provide a unique token on a page, send it as a first thing over SockJS
  connection and validate it on the server side. In essence, this is how cookies
  work.

To config SockJS clustering, see :doc:`Clustering with Akka and Hazelcast </cluster>`.

Chunked response
----------------

1. Call ``response.setChunked(true)``
2. Call respondXXX as many times as you want
3. Lastly, call ``respondLastChunk``

`Chunked response <http://en.wikipedia.org/wiki/Chunked_transfer_encoding>`_
has many use cases. For example, when you need to generate a very large CSV
file that does may not fit memory.

::

  // "Cache-Control" header will be automatically set to:
  // "no-store, no-cache, must-revalidate, max-age=0"
  // Note that "Pragma: no-cache" is linked to requests, not responses:
  // http://palizine.plynt.com/issues/2008Jul/cache-control-attributes/
  response.setChunked(true)

  val generator = new MyCsvGenerator
  val header = generator.getHeader
  respondText(header, "text/csv")

  while (generator.hasNextLine) {
    val line = generator.nextLine
    respondText(line)
  }

  respondLastChunk()

Notes:

* Headers are only sent on the first respondXXX call.
* :doc:`Page and action cache </cache>` cannot be used with chunked response.

Forever iframe
~~~~~~~~~~~~~~

Chunked response `can be used <http://www.shanison.com/2010/05/10/stop-the-browser-%E2%80%9Cthrobber-of-doom%E2%80%9D-while-loading-comet-forever-iframe/>`_
for `Comet <http://en.wikipedia.org/wiki/Comet_(programming)/>`_.

The page that embeds the iframe:

::

  ...
  <script>
    var functionForForeverIframeSnippetsToCall = function() {...}
  </script>
  ...
  <iframe width="1" height="1" src="path/to/forever/iframe"></iframe>
  ...

The action that responds <script> snippets forever:

::

  response.setChunked(true)

  // Need something like "123" for Firefox to work
  respondText("<html><body>123", "text/html")

  // Most clients (even curl!) do not execute <script> snippets right away,
  // we need to send about 2KB dummy data to bypass this problem
  for (i <- 1 to 100) respondText("<script></script>\n")

Later, whenever you want to pass data to the browser, just send a snippet:

::

  if (channel.isOpen)
    respondText("<script>parent.functionForForeverIframeSnippetsToCall()</script>\n")
  else
    // The connection has been closed, unsubscribe from events etc.
    // You can also use ``addConnectionClosedListener``.

Event Source
~~~~~~~~~~~~

See http://dev.w3.org/html5/eventsource/

Event Source response is a special kind of chunked response.
Data must be Must be  UTF-8.

To respond event source, call ``respondEventSource`` as many time as you want.

::

  respondEventSource("data1", "event1")
  respondEventSource("data2")  // Event name defaults to "message"
