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
* ``respondWebSocket``: responds a WebSocket text frame

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

WebSocket
---------

::

  import xitrum.Controller

  class HelloSockJS extends Controller {
    // /echo is the entry point
    def echo = WEBSOCKET("echo", new WebSocketHandler {
      def onOpen() {
        // If you don't want to accept the connection,
        // call channel.close()
        log.debug("onOpen")
      }

      def onMessage(text: String) {
        // Send back data to the SockJS client
        respondWebSocket(text.toUpperCase)
      }

      def onClose() {
        log.debug("onClose")
      }
    })
  }

To get URL to the above WebSocket action:

::

  object HelloWebSocket extends HelloWebSocket

  // Probably you want to use this in Scalate view etc.
  val url = HelloWebSocket.echo.webSocketAbsoluteUrl

Ajax long polling
-----------------

Chat example
~~~~~~~~~~~~

::

  import xitrum.Controller
  import xitrum.comet.CometController
  import xitrum.validator.{Required, Validated}

  class ChatController {
    def index = GET("chat") {
      jsCometGet("chat", """
        function(topic, timestamp, body) {
          var text = '- ' + xitrum.escapeHtml(body.chatInput[0]) + '<br />';
          xitrum.appendAndScroll('#chatOutput', text);
        }
      """)

      respondInlineView(
        <div id="chatOutput"></div>

        <form data-postback="submit" action={CometController.publish.url} data-after="$('#chatInput').value('')">
          <input type="hidden" name="topic" value="chat" class="required" />
          <input type="text" id="chatInput" name="chatInput" class="required" />
        </form>
      )
    }
  }

``jsCometGet`` will send long polling Ajax requests, get published messages,
and call your callback function. The 3rd argument ``body`` is a hash
containing everything inside the form commited to ``CometController``.

Publish message
~~~~~~~~~~~~~~~

In the example above, ``CometController`` will receive form post and publish
the message for you. If you want to publish the message yourself, call ``Comet.publish``:

::

  import xitrum.Controller
  import xitrum.comet.Comet

  class AdminController extends Controller {
    def index = GET("admin") {
      respondInlineView(
        <form data-postback="submit" action={publish.url}>
          <label>Message from admin:</label>
          <input type="text" name="body" class="required" />
        </form>
      )
    }

    def publish = POST("admin/chat") {
      val body = param("body")
      Comet.publish("chat", "[From admin]: " + body)
      respondText("")
    }
  }

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
