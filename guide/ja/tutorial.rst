チュートリアル
==============

本章ではXitrumプロジェクトを作成して実行するところまでを簡単に紹介します。

**このチュートリアルではJavaがインストールされたLinux環境を想定しています。**

Xitrumプロジェクトの作成
--------------------------

新規のプロジェクトを作成するには
`xitrum-new.zip <https://github.com/xitrum-framework/xitrum-new/archive/master.zip>`_ をダウンロードします。

::

  wget -O xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

または:

::

  curl -L -o xitrum-new.zip https://github.com/xitrum-framework/xitrum-new/archive/master.zip

起動
----

Scalaのビルドツールとしてデファクトスタンダードである `SBT <https://github.com/harrah/xsbt/wiki/Setup>`_ を使用します。
先ほどダウンロードしたプロジェクトには既に SBT 0.13 が ``sbt`` ディレクトリに梱包されています。
SBTを自分でインストールするには、SBTの `セットアップガイド <https://github.com/harrah/xsbt/wiki/Setup>`_ を参照してください。

作成したプロジェクトのルートディレクトリで ``sbt/sbt run`` と実行することでXitrumが起動します:

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

  [INFO] GET quickstart.action.SiteIndex, 1 [ms]

自動リロード
------------

開発モードでは、`target/scala-2.11/classes` ディレクトリ内のクラスファイルおよびルートをXitrumが自動的にリロードします。
そのため、`JRebel <http://zeroturnaround.com/software/jrebel/>`_ のようなツールを追加で使用する必要はありません。

Xitrumは新たなインスタンスを生成する際にnewを使用します。
Xitrumは既にインスタンスとして生成されたクラスはリロードしません。
例えば長く動き続けるスレッド上で生成され保持され続けるようなインスタンスは対象外となります。
多くのケースにおいてこれは十分であると言えます。

`target/scala-2.11/classes` ディレクトリ内に変更があった場合、以下の様なログが出力されます:

::

  [INFO] target/scala-2.11/classes changed; Reload classes and routes on next request

SBTを使用してソースコードの変更を監視し継続的にコンパイルを行うには、別のコンソールから以下のコマンドを実行します:

::

  sbt/sbt ~compile

EclipseやIntelliJを使用してソースコードの編集やコンパイルを行うことも可能です。

自動リロード対象外クラスの設定
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

デフォルトではクラスファイルリロード時にXitrumは新しいクラスローダーを生成し、
生成されたクラスローダーでは、全てのクラスがリロードされ、Scalaオブジェクトが初期化されます。

しかしプロジェクトには
例えば、重厚で初期化に時間がかかるクラスや、めったに変更されることのないクラスなど、
再ロードの対象外としたいファイルがいくつかあります。
また、以下の例のように、ユニークな名前を保持するScalaオブジェクトが再ロードによって初期化されてしまった場合、
``akka.actor.InvalidActorNameException: actor name [name goes here] is not unique!`` が発生してしまいます。

::

  package mypackage

  object WorkerPool {
    val numWorkers = Runtime.getRuntime.availableProcessors * 2
    val workers    = Seq.tabulate() { i =>
      val name = getClass.getName + "-" + i
      xitrum.Config.actorSystem.actorOf(Props[Worker], name)
    }
  }


自動リロード対象外のクラスを指定することで、親クラスローダー（システムクラスローダー）がロードしたクラスを
新しいクラスローダーから使用することができるようになります。

再ロードの対象外を指定するには:

::

  xitrum.DevClassLoader.ignorePattern = "mypackage\\.WorkerPool".r

もし、自動リロード機能自体を無効にする場合、Xitrum serverを起動する前にいかの1行を加えます:

::

  xitrum.Config.autoreloadInDevMode = false


Eclipseプロジェクトの作成
-------------------------

開発環境に `Eclipse <http://scala-ide.org/>`_ を使用する場合

プロジェクトディレクトリで以下のコマンドを実行します:

::

  sbt/sbt eclipse

``build.sbt`` に記載されたプロジェクト設定に応じてEclipse用の ``.project`` ファイルが生成されます。
Eclipseを起動してインポートしてください。

IntelliJ IDEAプロジェクトの作成
-------------------------------

開発環境に `IntelliJ IDEA <http://www.jetbrains.com/idea/>`_ を仕様する場合

プロジェクトディレクトリで以下のコマンドを実行します:

::

  sbt/sbt gen-idea

``build.sbt`` に記載されたプロジェクト設定に応じてIntelliJ用の ``.idea`` ファイルが生成されます。
IntelliJを起動してインポートしてください。


ignoreファイルの設定
--------------------

:doc:`チュートリアル </tutorial>` に沿ってプロジェクトを作成した場合 `ignored <https://github.com/xitrum-framework/xitrum-new/blob/master/.gitignore>`_ を参考にignoreファイルを作成してください。

::

  .*
  log
  project/project
  project/target
  routes.cache
  target
