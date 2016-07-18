非同期レスポンス
================

Actionからクライアントへレスポンスを返すには以下のメソッドを使用します

* ``respondView``: レイアウトファイルを使用または使用せずに、Viewテンプレートファイルを送信します
* ``respondInlineView``: レイアウトファイルを使用または使用せずに、インライン記述されたテンプレートを送信します
* ``respondText("hello")``: レイアウトファイルを使用せずに文字列を送信します
* ``respondHtml("<html>...</html>")``: contentTypeを"text/html"として文字列を送信します
* ``respondJson(List(1, 2, 3))``: ScalaオブジェクトをJSONに変換し、contentTypeを"application/json"として送信します
* ``respondJs("myFunction([1, 2, 3])")`` contentTypeを"application/javascript"として文字列を送信します
* ``respondJsonP(List(1, 2, 3), "myFunction")``: 上記2つの組み合わせをJSONPとして送信します
* ``respondJsonText("[1, 2, 3]")``: contentTypeを"application/javascript"として文字列として送信します
* ``respondJsonPText("[1, 2, 3]", "myFunction")``: `respondJs` 、 `respondJsonText` の2つの組み合わせをJSONPとして送信します
* ``respondBinary``: バイト配列を送信します
* ``respondFile``: ディスクからファイルを直接送信します。 `zero-copy <http://www.ibm.com/developerworks/library/j-zerocopy/>`_ を使用するため非常に高速です。
* ``respondEventSource("data", "event")``: チャンクレスポンスを送信します

Xitrumは自動でデフォルトレスポンスを送信しません。自分で明確に上記の``respondXXX``を呼ばなければなりません。
呼ばなければ、XitrumがそのHTTP接続を保持します。あとで``respondXXX``を読んでもいいです。

接続がopen状態になっているかを確認するには``channel.isOpen``を呼びます。``addConnectionClosedListener``
でコールバックを登録することもできませす。

::

  addConnectionClosedListener {
    // 切断されました。
    // リソース開放などをする。
  }

非同期なのでレスポンスはすぐに送信されません。``respondXXX`` の戻り値が
`ChannelFuture <http://netty.io/4.0/api/io/netty/channel/ChannelFuture.html>`_
となります。それを使って実際にレスポンスを送信されるコールバックを登録できます。

例えばレスポンスの送信あとに切断するには:

::

  import io.netty.channel.{ChannelFuture, ChannelFutureListener}

  val future = respondText("Hello")
  future.addListener(new ChannelFutureListener {
    def operationComplete(future: ChannelFuture) {
      future.getChannel.close()
    }
  })

より短い例:

::

  respondText("Hello").addListener(ChannelFutureListener.CLOSE)

WebSocket
---------

::

  import scala.runtime.ScalaRunTime
  import xitrum.annotation.WEBSOCKET
  import xitrum.{WebSocketAction, WebSocketBinary, WebSocketText, WebSocketPing, WebSocketPong}

  @WEBSOCKET("echo")
  class EchoWebSocketActor extends WebSocketAction {
    def execute() {
      // ここでセッションデータ、リクエストヘッダなどを抽出できますが
      // respondTextやrespondViewなどは使えません。
      // レスポンスするには以下のようにrespondWebSocketXXXを使ってください。

      log.debug("onOpen")

      context.become {
        case WebSocketText(text) =>
          log.info("onTextMessage: " + text)
          respondWebSocketText(text.toUpperCase)

        case WebSocketBinary(bytes) =>
          log.info("onBinaryMessage: " + ScalaRunTime.stringOf(bytes))
          respondWebSocketBinary(bytes)

        case WebSocketPing =>
          log.debug("onPing")

        case WebSocketPong =>
          log.debug("onPong")
      }
    }

    override def postStop() {
      log.debug("onClose")
      super.postStop()
    }
  }

リクエストが来る際に上記のアクターインスタンスが生成されます。次のときにアクターが停止されます:

* コネクションが切断されるとき
* WebSocketのcloseフレームが受信されるまたは送信されるとき

WebSocketフレームを送信するメソッド:

* ``respondWebSocketText``
* ``respondWebSocketBinary``
* ``respondWebSocketPing``
* ``respondWebSocketClose``

``respondWebSocketPong`` はありません。Xitrumがpingフレームを受信したら自動でpongフレームを
送信するからです。

上記のWebSocketアクションへのURLを取得するには:

::

  // Scalateテンプレートファイルなどで
  val url = absWebSocketUrl[EchoWebSocketActor]

SockJS
------

`SockJS <https://github.com/sockjs/sockjs-client>`_ とはWebSocketのようなAPIを提供
するJavaScriptライブラリです。WebSocketを対応しないブラウザで使います。SockJSがブラウザがの
WebSocketの機能の存在を確認し、存在しない場合、他の適切な通信プロトコルへフォルバックします。

WebSocket対応ブラウザ関係なくすべてのブラウザでWebSocket APIを使いたい場合、WebSocketを
直接使わないでSockJSを使ったほうがいいです。

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

XitrumがSockJSライブラリのファイルを含めており、テンプレートなどで以下のように書くだけでいいです:

::

  ...
  html
    head
      != jsDefaults
  ...

SockJSは `サーバー側の特別処理 <https://github.com/sockjs/sockjs-protocol>`_ が必要ですが、
Xitrumがその処理をやってくれるのです。

::

  import xitrum.{Action, SockJsAction, SockJsText}
  import xitrum.annotation.SOCKJS

  @SOCKJS("echo")
  class EchoSockJsActor extends SockJsAction {
    def execute() {
      // ここでセッションデータ、リクエストヘッダなどを抽出できますが
      // respondTextやrespondViewなどは使えません。
      // レスポンスするには以下のようにrespondSockJsXXXを使ってください。

      log.info("onOpen")

      context.become {
        case SockJsText(text) =>
          log.info("onMessage: " + text)
          respondSockJsText(text)
      }
    }

    override def postStop() {
      log.info("onClose")
      super.postStop()
    }
  }

新しいSockJSセッションが生成されるとき上記のアクターインスタンスが生成されます。セッションが
停止されるときにアクターが停止されます。

SockJSフレームを送信するには:

* ``respondSockJsText``
* ``respondSockJsClose``

`SockJsの注意事項 <https://github.com/sockjs/sockjs-node#various-issues-and-design-considerations>`_:

::

  クッキーがSockJsと合わないです。認証を実装するには自分でトークンを生成しSockJsページを埋め込んで、
  ブラウザ側からサーバー側へSockJs接続ができたらそのトークンを送信し認証すれば良い。クッキーが
  本質的にはそのようなメカニズムで動きます。

SockJSクラスタリングを構築するには :doc:`Akkaでサーバーをクラスタリングする </cluster>`
説明をご覧ください。

Chunkレスポンス
----------------

`Chunkレスポンス <http://en.wikipedia.org/wiki/Chunked_transfer_encoding>`_ を送信するには:

1. ``setChunked`` を呼ぶ
2. ``respondXXX`` を呼ぶ（複数回呼んでよい）
3. 最後に ``respondLastChunk`` を呼ぶ

Chunkレスポンスはいろいろな応用があります。例えばメモリがかかる大きなCSVファイルを一括で生成
できない場合、生成しながら送信して良い:

::

  // 「Cache-Control」ヘッダが自動で設定されます:
  // 「no-store, no-cache, must-revalidate, max-age=0」
  //
  // 因みに 「Pragma: no-cache」 ヘッダはレスポンスでなくリクエストのためです:
  // http://palizine.plynt.com/issues/2008Jul/cache-control-attributes/
  setChunked()

  val generator = new MyCsvGenerator

  generator.onFirstLine { line =>
    val future = respondText(header, "text/csv")
    future.addListener(new ChannelFutureListener {
      def operationComplete(future: ChannelFuture) {
        if (future.isSuccess) generator.next()
      }
    }
  }

  generator.onNextLine { line =>
    val future = respondText(line)
    future.addListener(new ChannelFutureListener {
      def operationComplete(future: ChannelFuture) {
        if (future.isSuccess) generator.next()
      }
    })
  }

  generator.onLastLine { line =>
    val future = respondText(line)
    future.addListener(new ChannelFutureListener {
      def operationComplete(future: ChannelFuture) {
        if (future.isSuccess) respondLastChunk()
      }
    })
  }

  generator.generate()

注意:

* ヘッダが最初の ``respondXXX`` で送信されます。
* 末尾ヘッダがオプションで ``respondLastChunk`` に設定できます。
* :doc:`ページとアクションキャッシュ </cache>` はchunkレスポンスとは使えません。

Chunkレスポンスを ``ActorAction`` の組み合わせて
`Facebook BigPipe <http://www.cubrid.org/blog/dev-platform/faster-web-page-loading-with-facebook-bigpipe/>`_
が実装できます。

無限iframe
~~~~~~~~~~~

Chunkレスポンスで `Comet <http://en.wikipedia.org/wiki/Comet_%28programming%29>`_ を
実装することが
`可能 <http://www.shanison.com/2010/05/10/stop-the-browser-%E2%80%9Cthrobber-of-doom%E2%80%9D-while-loading-comet-forever-iframe/>`_
です。

Iframeを含めるページ:

::

  ...
  <script>
    var functionForForeverIframeSnippetsToCall = function() {...}
  </script>
  ...
  <iframe width="1" height="1" src="path/to/forever/iframe"></iframe>
  ...

無限 ``<script>`` を生成するアクションで:

::

  // 準備

  setChunked()

  // Firefox対応
  respondText("<html><body>123", "text/html")

  // curlを含む多くのクライアントが<script>をすぐに出しません。
  // 2KB仮データで対応。
  for (i <- 1 to 100) respondText("<script></script>\n")

そのあと実際データを送信するには:

::

  if (channel.isOpen)
    respondText("<script>parent.functionForForeverIframeSnippetsToCall()</script>\n")
  else
    // 切断されました。リソースなどを開放。
    // ``addConnectionClosedListener``を使って良い。

Event Source
~~~~~~~~~~~~

参考: http://dev.w3.org/html5/eventsource/

Event SourceはデータがUTF-8でchunkレスポンスの一種です。

Event Sourceをレスポンスするには ``respondEventSource`` を呼んでください（複数回可）:

::

  respondEventSource("data1", "event1")  // イベント名が「event1」となります
  respondEventSource("data2")            // イベント名がデフォルトで「message」となります
