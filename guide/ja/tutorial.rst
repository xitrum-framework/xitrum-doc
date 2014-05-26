チュートリアル
==============

本章ではXitrumプロジェクトを作成して実行するところまでを紹介します。
**このチュートリアルではJavaがインストールされたLinux環境を想定しています。**

Xitrumプロジェクトの作成
--------------------------

新規のプロジェクトを作成するには
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_ をダウンロードします。

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

または、

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

起動
----

Scalaのビルドツールとしてデファクトスタンダードである `SBT <https://github.com/harrah/xsbt/wiki/Setup>`_ を使用します。
先ほどダウンロードしたプロジェクトには既に SBT 0.13.1 が ``sbt`` ディレクトリに梱包されています。
SBTを自分でインストールするには、SBTの `セットアップガイド <https://github.com/harrah/xsbt/wiki/Setup>`_ を参照してください。

作成したプロジェクトのルートディレクトリで ``sbt/sbt run`` と実行することでXitrumが起動します。

::

  unzip xitrum-new.zip
  cd xitrum-new
  sbt/sbt run


このコマンドは依存ライブラリ( :doc:`dependencies </deps>` )のダウンロード, およびプロジェクトのコンパイルを実行後、
``quickstart.Boot`` クラスが実行され、WEBサーバーが起動します。
コンソールには以下の様なルーティング情報が表示されます。

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

初回起動時には、全てのルーティングが収集されログに出力されます。
この情報はアプリケーションのRESTful APIについてドキュメントを書く場合この情報はとても役立つことでしょう。

ブラウザで `http://localhost:8000 <http://localhost:8000/>`_ もしくは `https://localhost:4430 <http://localhost:4430/>`_ にアクセスしてみましょう。
次のようなリクエスト情報がコンソールから確認できます。

::

  [DEBUG] GET quickstart.action.SiteIndex, 1 [ms]
